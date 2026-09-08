# WAYFARER — Web公開

公開URL: https://tsukushibito.github.io/wayfarer/

Godot 4.7.2製RTSのWebリリース配信リポジトリです。`public/`の成果物を
GitHub ActionsでGitHub Pagesへ公開します。ソースは
[rts-base-system](https://github.com/tsukushibito/rts-base-system)で管理します。

## 遊び方

デスクトップのWebGL 2.0対応ブラウザで公開URLを開きます。
初回は約75 MiBを読み込みます。タイトル画面の案内で操作を確認できます。
保存はJ、読込はK、全画面はU。セーブデータは利用ブラウザ内に保存されます。

## 更新

Godot 4.7.2本体と同版Web exportテンプレートのある開発環境で実行します。

```bash
bash scripts/update-build.sh /path/to/rts-base-system
git add public
git commit -m "deploy: update WAYFARER Web build"
git push origin main
```

`main`へのpushで`.github/workflows/pages.yml`が検査・公開します。
GitHubのSettings → Pages → SourceはGitHub Actionsです。
`public/build-info.json`に元コミット・エンジン版、`SHA256SUMS`に整合性情報を記録します。
過去版に戻す場合は該当する更新コミットをrevertしてpushします。

Web版は単一スレッド・Compatibility描画です。ネイティブ版の見た目・性能とは差があります。
保存検査の同期待ちを修正し、公開版で保存・再読み込み・復元後の再保存を確認しています。
原因と検証結果は[Web保存検査の検証](https://github.com/tsukushibito/rts-base-system/blob/main/docs/quality/web-save-validation-2026-09-08.md)を参照してください。
フォント・音源・Godotのライセンス通知は公開成果物に同梱しています。

構成参考: [GitHub Pages公式](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)、
[Godot Web export公式](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html)。
