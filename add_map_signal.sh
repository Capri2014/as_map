#!/usr/bin/env bash

# add signal
if [ ! -e /apollo ]; then
    echo "must run this script in /apollo folder in side docker"
    exit 0
fi

if [ $# == 0 ]; then
    echo "$0 basemap drive_event1 drive_event2 ..."
    exit 0
fi

cd /apollo
basemap=$1
shift
cp $basemap base_map.txt
map_dir=$(basename $basemap)
map_dir="modules/map/data/${map_dir%.*}"
mkdir -p $map_dir
for signal in $@; do
    python modules/tools/map_gen/create_traffic_light_from_event.py --extend_to_neighbor_lane $signal $signal.signal.txt
    echo "$signal ==> $signal.signal.txt"
    python modules/tools/map_gen/add_signal.py base_map.txt $signal.signal.txt
    mv "base_map.txt_${signal}.signal.txt" base_map.txt
done
cp base_map.txt $map_dir/
 ./bazel-bin/modules/map/tools/sim_map_generator --map_dir=$map_dir  --output_dir=$map_dir
bash scripts/generate_routing_topo_graph.sh --map_dir=$map_dir

echo "Created map in $map_dir/"
