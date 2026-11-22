# ビルドと更新

データセットの概要は [README.md](README.md) にあります。ここにはこのリポジトリでデータセットをビルド・更新する手順を書きます。

## 更新

### 指定緊急避難場所（mart_tsukuba_emergency_shelter）

公式 CSV が更新されたら、`scripts/convert_shelter.py` で seeds を再生成します。住所の照合には Queria のジオコーダー（https://geocoder.queria.io）を使います。

```bash
uv run python scripts/convert_shelter.py \
    https://www.city.tsukuba.lg.jp/soshikikarasagasu/shichokoshitsukikikanrika/gyomuannai/1/2/1000608.html \
    seeds/tsukuba_emergency_shelter_20241201.csv
```

出力時点のファイル名（`20241201` 部分）は、つくば市公式ページの更新時点に合わせて付けます。
