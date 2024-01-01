# Soda (Abandoned)
The main purpose of this  project is to watch videos, view images and most of the documents from HTML server/open directory without downloading them. 

<img src="https://github.com/jazzsim/soda/assets/24294128/c4f132dd-e291-4852-ac7f-22102d081a26" width="500" height="300">
<img src="https://github.com/jazzsim/soda/assets/24294128/d7c3557b-47db-4df2-b68c-56cd5ecd1649" width="500" height="300">
<img src="https://github.com/jazzsim/soda/assets/24294128/0c5f7e2e-8314-4c09-8af7-ad8ec8529951" width="500" height="300">
<img src="https://github.com/jazzsim/soda/assets/24294128/c2df60e6-bb1c-4b6e-9dc3-4579840718f4" width="500" height="300">


# Challanges met
1. Video\
  The main issue for both web and app platforms is the container incompatibility with ```video_player 2.8.1```. Most of the video contents hosted on the servers contain various file types such as .mp4, .avi, .mkv, .m4v, .webm, etc. Some of the formats listed are not yet supported by the package on one platform or both platforms.

2. Images\
  CORS issue was encountered while loading images on the web platform. Since we are loading the image from other domains and have no controls over the CORS policy, the images would be blocked by CORS policy.

3. Documemts\
  A pdf viewer was implemented on app through ```pdfx 2.5.0```. The viewing pdf and pdf thumbnail generation works on app but not on web due to this project's Flutter version (```3.2.0```) conflicting with the web support of ```pdfx 2.5.0```.

# Moving forward
This project will not be continued with Flutter as of 2024-01-01. A new project will be develop in either C++, C# or Python.
