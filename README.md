# UMBRELLA - 5G and 6G Coverage Simulation

## 📌 Description
This project presents an open-source MATLAB simulation for planning the deployment of base stations for 5G and future 6G networks in urban environments. The tool enables coverage visualization based on terrain characteristics and features an interactive interface that allows users to adjust parameters such as operating frequency and propagation scenario.

## 🚀 Features
- 5G simulation with NYU model (0.5 - 6 GHz)
- 6G simulation in sub-THz bands (6 - 70 GHz)
- Interactive interface for parameter adjustment
- Coverage visualization based on terrain characteristics

## 📁 Project Files
- `UMBRELLA.mlapp` - Main MATLAB application
- `arequipa_ak.tif` - Terrain map for simulation

## 🔧 Requirements
- MATLAB R2020a or higher
- Toolboxes:
  - Statistics and Machine Learning Toolbox
  - Image Processing Toolbox (for .tif handling)

## 📊 Propagation Models
- **NYU (5G):** 0.5 - 150 GHz, UMi and UMa scenarios
- **Sub-THz (6G):** 100 - 300 GHz, with molecular absorption

## 📖 How to Use
1. Open `UMBRELLA.mlapp` in MATLAB
2. Select frequency and propagation scenario
3. Visualize coverage on the map
4. Consider this program helps visualize the coverage of various antennas across different geographic locations, as required.

   The location can be changed as needed by downloading a new TIFF file and adding it to the code at line 511.

   A webpage is provided where these images can be downloaded, but they cover only Peru; if you wish to analyze an area outside this country, you will need to obtain the data from another source.
  
 ** GEO GPS PERU: https://www.geogpsperu.com/2018/08/descargar-imagenes-aster-gdem-aster.html

-	`function [L_p]`; verifies that input ranges are correct.
-	`function [factor_corr]`; calculates the correction based on city size and frequency.
-	`function A_perdidas =` calculates losses for 5G, 6G, and Okumura-Hata models.
-	`function [d_max] = calcular_distancia_maxima`; determines the maximum distance based on the city type (urban, suburban, or rural).
-	`function G = calcular_ganancia_antena_sectorizada`; calculates the antenna gain.
-	`function azimut_normalizado`; calculates the antenna azimuth.
- Line 207 corresponds to the Sub-THz (6G) propagation model.
- Lines 250–255 correspond to the NYU (5G) propagation models.
- Another point to consider is that the frequencies must be entered in MHz.

## 📜 License
This project is licensed under the MIT License. See the `LICENSE` file for details.

## 👩‍💻 Author
- Danna Arizaca
- Maria Moscoso
