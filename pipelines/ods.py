"""自治体標準オープンデータセットの各一覧を CKAN から取得する。

データセットごとに CKAN の ID が決まっているので、package_show でリソースを引く。
CSV は CP932 で配られているため、取得の時点で UTF-8 に揃える。
"""

from __future__ import annotations

import csv
import logging
from pathlib import Path

from openpyxl import load_workbook

from pipelines.ckan import download, package_resources

logger = logging.getLogger("pipelines.ods")

PUBLIC_WIRELESS_LAN = "k006_001"
FIRE_HYDRANT = "n007_001"
POLLING_PLACE = "m027_001"

# 投票所一覧は地区ごとにシートが分かれている。このヘッダーで始まるシートだけを読む
# （同じブックに行政区と学区の対応表のシートが同居している）
POLLING_PLACE_HEADER = ["№", "投票区番号", "投票区", "投票所", "投票所住所", "対象地区"]


def download_public_wireless_lan(dest: str) -> list[Path]:
    resources = package_resources(PUBLIC_WIRELESS_LAN, "CSV")
    # 時点の違う CSV が並ぶと同じアクセスポイントが二重に入る。どれを採るかは人が決める
    if len(resources) != 1:
        raise SystemExit(
            f"public_wireless_lan: CSV が {len(resources)} 件ある (1 件のはず)。上流の構成が変わった"
        )
    return download(resources, Path(dest), normalize_encoding=True)


def download_fire_hydrant(dest: str) -> list[Path]:
    # 防火水槽と消火栓が別の CSV で載っている。種別は各 CSV の列が持つ
    resources = package_resources(FIRE_HYDRANT, "CSV")
    if not resources:
        raise SystemExit("fire_hydrant: CSV が 1 件も無い。上流の構成が変わった")
    return download(resources, Path(dest), normalize_encoding=True)


def download_polling_place(dest: str, out: str) -> Path:
    """投票所一覧の XLSX を取得し、地区別のシートを縦につないだ CSV を `out` に書く。

    1 列目には元のシート名（地区）を入れる。合計行などの選別は dbt 側でする。
    """
    resources = package_resources(POLLING_PLACE, "XLSX")
    if len(resources) != 1:
        raise SystemExit(
            f"polling_place: XLSX が {len(resources)} 件ある (1 件のはず)。上流の構成が変わった"
        )
    (xlsx,) = download(resources, Path(dest))

    rows: list[list[str]] = []
    sheets: list[str] = []
    for ws in load_workbook(xlsx, read_only=True, data_only=True).worksheets:
        values = list(ws.iter_rows(values_only=True))
        if not values or [_cell(v) for v in values[0][: len(POLLING_PLACE_HEADER)]] != POLLING_PLACE_HEADER:
            continue
        sheets.append(ws.title)
        for row in values[1:]:
            cells = [_cell(v) for v in row[: len(POLLING_PLACE_HEADER)]]
            if any(cells):
                rows.append([ws.title, *cells])
    if not sheets:
        raise SystemExit("polling_place: 投票所のシートが見つからない。上流の様式が変わった")

    path = Path(out)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["地区", *POLLING_PLACE_HEADER])
        writer.writerows(rows)
    logger.info("polling_place: %d シート %d 行 (%s)", len(sheets), len(rows), "、".join(sheets))
    return path


def _cell(value: object) -> str:
    return "" if value is None else str(value).strip()
