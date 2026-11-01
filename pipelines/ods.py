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

# 消防水利の CSV は防火水槽と消火栓の 2 本
FIRE_HYDRANT_CSVS = 2

# 投票所一覧は地区ごとにシートが分かれている。このヘッダーで始まるシートだけを読む
# （同じブックに行政区と学区の対応表のシートが同居している）
POLLING_PLACE_HEADER = ["№", "投票区番号", "投票区", "投票所", "投票所住所", "対象地区"]
# 地区別のシートは 6 枚（2024年7月時点）。1 枚でも様式が変わって読めなくなると、
# その地区の投票所が黙って抜けるので、下回ったら止める
MIN_POLLING_PLACE_SHEETS = 6


def download_public_wireless_lan(dest: str) -> list[Path]:
    _clear_csv(Path(dest))
    resources = package_resources(PUBLIC_WIRELESS_LAN, "CSV")
    # 時点の違う CSV が並ぶと同じアクセスポイントが二重に入る。どれを採るかは人が決める
    if len(resources) != 1:
        raise SystemExit(
            f"public_wireless_lan: CSV が {len(resources)} 件ある (1 件のはず)。上流の構成が変わった"
        )
    return download(resources, Path(dest), normalize_encoding=True)


def download_fire_hydrant(dest: str) -> list[Path]:
    # 防火水槽と消火栓が別の CSV で載っている。種別は各 CSV の列が持つ。
    # 時点の違う CSV が足されると、raw は glob で読むので同じ水利が二重に入る。
    # 支援系水利番号は元から重複があり一意性のテストで拾えないので、本数で止める
    _clear_csv(Path(dest))
    resources = package_resources(FIRE_HYDRANT, "CSV")
    if len(resources) != FIRE_HYDRANT_CSVS:
        raise SystemExit(
            f"fire_hydrant: CSV が {len(resources)} 件ある ({FIRE_HYDRANT_CSVS} 件のはず)。上流の構成が変わった"
        )
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
    skipped: list[str] = []
    wb = load_workbook(xlsx, read_only=True, data_only=True)
    try:
        for ws in wb.worksheets:
            values = list(ws.iter_rows(values_only=True))
            if not values or [_cell(v) for v in values[0][: len(POLLING_PLACE_HEADER)]] != POLLING_PLACE_HEADER:
                skipped.append(ws.title)
                continue
            sheets.append(ws.title)
            for row in values[1:]:
                cells = [_cell(v) for v in row[: len(POLLING_PLACE_HEADER)]]
                if any(cells):
                    rows.append([ws.title, *cells])
    finally:
        wb.close()
    if skipped:
        logger.warning("polling_place: 投票所の様式でないシートを読み飛ばした (%s)", "、".join(skipped))
    if len(sheets) < MIN_POLLING_PLACE_SHEETS:
        raise SystemExit(
            f"polling_place: 投票所のシートが {len(sheets)} 枚しかない ({MIN_POLLING_PLACE_SHEETS} 枚のはず)。上流の様式が変わった"
        )

    path = Path(out)
    with path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(["地区", *POLLING_PLACE_HEADER])
        writer.writerows(rows)
    logger.info("polling_place: %d シート %d 行 (%s)", len(sheets), len(rows), "、".join(sheets))
    return path


def _clear_csv(dest: Path) -> None:
    """前回の取得で残った CSV を消す。raw は glob で読むので、時点の違うファイルが残ると二重に入る"""
    for path in dest.glob("*.csv"):
        path.unlink()


def _cell(value: object) -> str:
    return "" if value is None else str(value).strip()
