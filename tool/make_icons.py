"""Family Day 웹 앱 아이콘(홈 화면 추가용)을 그린다.

`web/icons/`, `web/favicon.png` 를 브랜드 팔레트(네이비→코발트 그라데이션 + 골드 번개)로
다시 만든다. 실행: python3 tool/make_icons.py
"""

from __future__ import annotations

import os

from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
WEB = os.path.join(HERE, "..", "web")

NAVY = (13, 27, 51)
COBALT = (37, 99, 235)
GOLD = (247, 183, 51)

# 0~1 좌표의 번개 모양(왼쪽 위 → 오른쪽 아래).
BOLT = [
    (0.575, 0.075),
    (0.275, 0.555),
    (0.452, 0.555),
    (0.395, 0.925),
    (0.725, 0.435),
    (0.548, 0.435),
]


def gradient(size: int) -> Image.Image:
    """좌상단 네이비 → 우하단 코발트 대각선 그라데이션."""
    small = Image.new("RGB", (96, 96))
    pixels = small.load()
    for y in range(96):
        for x in range(96):
            t = (x + y) / (2 * 95)
            pixels[x, y] = (
                round(NAVY[0] + (COBALT[0] - NAVY[0]) * t),
                round(NAVY[1] + (COBALT[1] - NAVY[1]) * t),
                round(NAVY[2] + (COBALT[2] - NAVY[2]) * t),
            )
    return small.resize((size, size), Image.LANCZOS)


def icon(size: int, *, bolt_scale: float = 1.0, radius_ratio: float = 0.0) -> Image.Image:
    """그라데이션 배경 위에 골드 번개를 얹은 아이콘."""
    base = gradient(size)
    if radius_ratio > 0:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, size - 1, size - 1], radius=round(size * radius_ratio), fill=255
        )
        base.putalpha(mask)

    # 번개는 아이콘 가운데에 bolt_scale 비율로 배치.
    span = size * 0.70 * bolt_scale
    offset_x = (size - span) / 2
    offset_y = (size - span) / 2
    points = [(offset_x + x * span, offset_y + y * span) for x, y in BOLT]

    overlay = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(overlay).polygon(points, fill=GOLD + (255,))
    base = Image.alpha_composite(base.convert("RGBA"), overlay)
    return base


def main() -> None:
    icons_dir = os.path.join(WEB, "icons")
    os.makedirs(icons_dir, exist_ok=True)

    out = {
        "Icon-180.png": icon(180),
        "Icon-192.png": icon(192, radius_ratio=0.22),
        "Icon-512.png": icon(512, radius_ratio=0.22),
        # maskable: 여백을 두고 꽉 찬 배경(안드로이드가 알아서 잘라낸다).
        "Icon-maskable-192.png": icon(192, bolt_scale=0.74),
        "Icon-maskable-512.png": icon(512, bolt_scale=0.74),
    }
    for name, image in out.items():
        image.save(os.path.join(icons_dir, name))

    icon(64).save(os.path.join(WEB, "favicon.png"))
    print("아이콘 생성 완료:", ", ".join(out), "+ favicon.png")


if __name__ == "__main__":
    main()
