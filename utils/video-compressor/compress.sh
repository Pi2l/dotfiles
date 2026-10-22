#!/usr/bin/env bash

set -e

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "Error: ffmpeg is not installed or not in PATH." >&2
    exit 1
fi

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <input_file> [mode]"
    echo ""
    echo "Modes:"
    echo "  balance       - H.265 / HEVC, optimal compromise (default)"
    echo "  max-size      - AV1, maximum compression with great quality"
    echo "  max-quality   - H.264, visually indistinguishable quality (CRF 17)"
    echo "  truelossless  - H.264 CRF 0, mathematically lossless quality"
    exit 1
fi

INPUT_FILE="$1"
MODE="${2:-balance}"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found." >&2
    exit 1
fi

# Extract directory, base name, and filename
DIR_NAME="$(dirname "$INPUT_FILE")"
BASE_NAME="$(basename "$INPUT_FILE")"
FILENAME="${BASE_NAME%.*}"

# Configure options based on mode
case "$MODE" in
    balance)
        OUTPUT_EXT="mp4"
        FFMPEG_OPTS=(
            -c:v libx265
            -crf 26
            -preset slow
            -tag:v hvc1
            -c:a copy
        )
        ;;
    max-size)
        OUTPUT_EXT="mp4"
        FFMPEG_OPTS=(
            -c:v libsvtav1
            -crf 34
            -preset 5
            -svtav1-params tune=0
            -c:a copy
        )
        ;;
    max-quality)
        OUTPUT_EXT="mp4"
        FFMPEG_OPTS=(
            -c:v libx264
            -crf 22
            -preset slow
            -c:a copy
        )
        ;;
    trueloseless|truelossless)
        OUTPUT_EXT="mp4"
        MODE="truelossless"
        FFMPEG_OPTS=(
            -c:v libx264
            -crf 0
            -preset medium
            -c:a copy
        )
        ;;
    *)
        echo "Error: Unknown mode '$MODE'." >&2
        echo "Available modes: balance, max-size, max-quality, truelossless" >&2
        exit 1
        ;;
esac

OUTPUT_FILE="${DIR_NAME}/${FILENAME}-compressed-${MODE}.${OUTPUT_EXT}"

echo "Input file : $INPUT_FILE"
echo "Mode       : $MODE"
echo "Output file: $OUTPUT_FILE"
echo "Starting encoding..."

ffmpeg -hide_banner -loglevel warning -stats -i "$INPUT_FILE" "${FFMPEG_OPTS[@]}" "$OUTPUT_FILE"

echo "Done! Saved to: $OUTPUT_FILE"
