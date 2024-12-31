#!/bin/bash


unzip original_data.zip
ogrinfo /vsizip/OLC_Willamette_Valley_Swaths_OGIC.zip/OLC_Willamette_Valley_Swaths_OGIC.shp OLC_Willamette_Valley_Swaths_OGIC -so


ogr2ogr OLC_Willamette_Valley_Swaths_OGIC.parquet /vsizip/OLC_Willamette_Valley_Swaths_OGIC.zip/OLC_Willamette_Valley_Swaths_OGIC.shp -sql "SELECT FlightDate,Line_ID,Lift_ID, CAST(StartTime AS float), CAST(EndTime AS float) FROM OLC_Willamette_Valley_Swaths_OGIC"

export IFS=
read -r -d '' pipeline << EOM
[
    {
        "type": "readers.las",
        "filename": "./Autzen_Stadium/s06360w08490.las"
    },
    {
        "type": "readers.las",
        "filename": "./Autzen_Stadium/s06360w08520.las"
    },
    {
        "type": "filters.reprojection",
        "out_srs": "EPSG:2991+6360"
    },
    {
        "type": "filters.merge"
    },

        {
            "type":"writers.copc",
            "where":"Withheld !=1",
            "offset_x":"auto",
            "offset_y":"auto",
            "offset_z":"auto",
            "forward":"all",
            "filename":"autzen-2023.copc.laz",
            "vlrs":[{"description": "ASPRS Classification Lookup", "record_id": 0, "user_id": "LASF_Spec", "data": "Akdyb3VuZAAAAAAAAAAAAAJHcm91bmQAAAAAAAAAAAAFVmVnZXRhdGlvbgAAAAAABkJ1aWxkaW5nAAAAAAAAAAlXYXRlcgAAAAAAAAAAAAAPVHJhbnNtaXNzaW9uIFRvEUJyaWRnZSBEZWNrAAAAABNPdmVyaGVhZCBTdHJ1Y3RAV2lyZQAAAAAAAAAAAAAAQUNhcgAAAAAAAAAAAAAAAEJUcnVjawAAAAAAAAAAAABDQm9hdAAAAAAAAAAAAAAAREJhcnJpZXIAAAAAAAAAAEVSYWlscm9hZCBDYXIAAABGRWxldmF0ZWQgV2Fsa3dhR0NvdmVyZWQgV2Fsa3dheUhQaWVyL0RvY2sAAAAAAABJRmVuY2UAAAAAAAAAAAAASlRvd2VyAAAAAAAAAAAAAEtDcmFuZQAAAAAAAAAAAABMU2lsby9TdG9yYWdlAAAATUJyaWRnZSBTdHJ1Y3R1cg=="}, {"description": "application/vnd.apache.parquet", "record_id": 3412, "user_id": "metadata", "filename": "./OLC_Willamette_Valley_Swaths_OGIC.parquet"},{"description": "application/xml", "record_id": 2222, "user_id": "metadata", "filename": "./OLC_Willamette_Valley_Classified_LAS_Metadata.xml"},{"description": "application/pdf", "record_id": 3413, "user_id": "metadata", "filename": "./OLC_WillametteValley_2023_NIR_Lidar_Report.pdf"}]
        }
]
EOM


echo $pipeline | pdal pipeline --writers.copc.node_threshold=32768 --stdin

#/Users/hobu/dev/git/untwine/build/untwine -i autzen.laz -o autzen-classified.copc.laz --single_file


