#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
抓取维基百科中文 API 的「历史上的今天」，
按 月_日 生成 366 个 JSON，落到 assets/data/history/。

用法:
    python3 tools/gen_history.py

只落真实抓取到的数据；抓不到就跳过该日（不造假数据），运行时走在线接口。
输出字段为短名：y=年份 t=文本 c=分类 u=链接
"""
import json
import os
import re
import sys
import time
import urllib.request
import urllib.error

BASE = "https://zh.wikipedia.org/api/rest_v1/feed/onthisday"
OUT_DIR = os.path.join("assets", "data", "history")
UA = "Rili/1.0 (https://github.com/yourname/rili)"

TYPES = [("events", "大事件"), ("births", "出生"), ("deaths", "逝世")]
DAYS_IN_MONTH = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

TIMEOUT = 20
RETRY = 3
SLEEP = 0.5
MAX_PER_TYPE = 20

TAG = re.compile(r"<[^>]+>")
ENT = {"&quot;": '"', "&amp;": "&", "&lt;": "<", "&gt;": ">", "&#39;": "'"}


def clean(s):
    s = TAG.sub("", s or "")
    for k, v in ENT.items():
        s = s.replace(k, v)
    return s.strip()


def fetch(url):
    for i in range(RETRY + 1):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:
            print(f"  ! 第{i+1}次失败 {url} -> {e}", file=sys.stderr)
            time.sleep(1.5 * (i + 1))
    return None


def norm(items, category):
    out = []
    for e in items[:MAX_PER_TYPE]:
        if not isinstance(e, dict):
            continue
        year = e.get("year")
        text = clean(e.get("text"))
        if not isinstance(year, int) or not text:
            continue
        url = None
        pages = e.get("pages") or []
        if pages and isinstance(pages[0], dict):
            desk = (pages[0].get("content_urls") or {}).get("desktop") or {}
            url = desk.get("page")
        item = {"y": year, "t": text, "c": category}
        if url:
            item["u"] = url
        out.append(item)
    return out


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    total_days = total_items = 0
    for m in range(1, 13):
        for d in range(1, DAYS_IN_MONTH[m - 1] + 1):
            day_items = []
            data = fetch(f"{BASE}/all/{m:02d}/{d:02d}")
            if data:
                for key, cat in TYPES:
                    day_items += norm(data.get(key) or [], cat)
                time.sleep(SLEEP)
            else:
                for key, cat in TYPES:
                    sub = fetch(f"{BASE}/{key}/{m:02d}/{d:02d}")
                    if sub:
                        day_items += norm(sub.get(key) or [], cat)
                    time.sleep(SLEEP)

            seen, uniq = set(), []
            for it in day_items:
                k = (it["y"], it["t"])
                if k not in seen:
                    seen.add(k)
                    uniq.append(it)
            uniq.sort(key=lambda x: x["y"], reverse=True)

            path = os.path.join(OUT_DIR, f"history_{m}_{d}.json")
            if uniq:
                with open(path, "w", encoding="utf-8") as f:
                    json.dump(uniq, f, ensure_ascii=False, separators=(",", ":"))
                total_days += 1
                total_items += len(uniq)
                print(f"  OK {m:>2}/{d:<2} {len(uniq):>3}")
            else:
                print(f"  -- {m:>2}/{d:<2} 跳过（无数据）")
    print(f"\n完成：{total_days} 天 / {total_items} 条 -> {OUT_DIR}/")


if __name__ == "__main__":
    main()
