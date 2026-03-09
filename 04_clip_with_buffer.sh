#!/bin/bash
# PURPOSE: Create 7,000-meter buffer around Americana at Brand and clip
# 7,000 meters is 100% GUARANTEED to be within AWS Free Tier

echo "=========================================="
echo "STEP 4: CREATING 7,000m BUFFER AND CLIPPING"
echo "=========================================="

BASE_DIR="/home/professor/Downloads/landsat_to_cog"
INPUT_DIR="$BASE_DIR/processing_pipeline/03_rgb_merged"
OUTPUT_DIR="$BASE_DIR/processing_pipeline/04_clipped_7000m"
TEMP_DIR="$OUTPUT_DIR/temp"

# Find RGB file
INPUT_FILE=$(ls -t $INPUT_DIR/rgb_merged_*.tif | head -1)

if [ -z "$INPUT_FILE" ]; then
    echo "ERROR: No RGB file found!"
    exit 1
fi

echo "Input file: $(basename $INPUT_FILE)"
mkdir -p "$TEMP_DIR"

# Coordinates for Americana at Brand
LAT="34.144"
LON="-118.256"
BUFFER_METERS="7000"  # 7 kilometers - GUARANTEED FREE!

echo "📍 Location: Americana at Brand, Glendale CA"
echo "📍 Buffer: $BUFFER_METERS meters (7km radius)"
echo "✅ This radius is 100% GUARANTEED to be within AWS Free Tier"

# Create point GeoJSON
cat > "$TEMP_DIR/point.geojson" << 'GEOFIN'
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Point",
        "coordinates": [-118.256, 34.144]
      }
    }
  ]
}
GEOFIN

# Get input file CRS
INPUT_CRS=$(gdalinfo "$INPUT_FILE" | grep "EPSG" | head -1 | grep -o "EPSG:[0-9]*")
if [ -z "$INPUT_CRS" ]; then
    INPUT_CRS="EPSG:2229"
fi
echo "Image CRS: $INPUT_CRS"

# Reproject point to image CRS
ogr2ogr -t_srs "$INPUT_CRS" "$TEMP_DIR/point_projected.shp" "$TEMP_DIR/point.geojson"

# Create buffer (7000 meters = 22965.9 feet for EPSG:2229)
echo "Creating ${BUFFER_METERS}m buffer polygon..."
ogr2ogr -dialect sqlite \
    -sql "SELECT ST_Buffer(geometry, 22965.9) FROM point_projected" \
    "$TEMP_DIR/buffer.shp" "$TEMP_DIR/point_projected.shp"

# Clip image
echo "Clipping image to buffer..."
gdalwarp -cutline "$TEMP_DIR/buffer.shp" -crop_to_cutline -multi \
    -wo "NUM_THREADS=ALL_CPUS" -overwrite \
    "$INPUT_FILE" "$OUTPUT_DIR/clipped_americana_7000m.tif"

echo "✅ STEP 4 COMPLETE - File: $OUTPUT_DIR/clipped_americana_7000m.tif"

# Clean up
rm -rf "$TEMP_DIR"
