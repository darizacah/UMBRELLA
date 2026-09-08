classdef Testex_6G_ < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        GridLayout                    matlab.ui.container.GridLayout
        CellularCoverageandLinkBudgetLabel  matlab.ui.control.Label
        TabGroup                      matlab.ui.container.TabGroup
        IntroductionTab               matlab.ui.container.Tab
        GridLayout6                   matlab.ui.container.GridLayout
        EsteproyectotienecomoobjetivoLabel  matlab.ui.control.Label
        IntegrantesGomezValderramaAnaLucilaLabel  matlab.ui.control.Label
        MediumTab                     matlab.ui.container.Tab
        GridLayout3                   matlab.ui.container.GridLayout
        FrequencyEditFieldLabel       matlab.ui.control.Label
        FrequencyEditField            matlab.ui.control.NumericEditField
        PowerLabel                    matlab.ui.control.Label
        PtxEditField                  matlab.ui.control.NumericEditField
        GainLabel                     matlab.ui.control.Label
        GananciaEditFieldTx           matlab.ui.control.NumericEditField
        GainLabel_2                   matlab.ui.control.Label
        GananciaEditField_Rx          matlab.ui.control.NumericEditField
        SensitivityLabel              matlab.ui.control.Label
        Prx_minEditField              matlab.ui.control.NumericEditField
        TransmissionLabel             matlab.ui.control.Label
        ReceptionLabel                matlab.ui.control.Label
        AntennaTab                    matlab.ui.container.Tab
        GridLayout4                   matlab.ui.container.GridLayout
        HeightEditFieldLabel          matlab.ui.control.Label
        HeightEditField               matlab.ui.control.NumericEditField
        nguloAperturaLabel            matlab.ui.control.Label
        OpeningAngleEditField         matlab.ui.control.NumericEditField
        ConnectorsEditFieldLabel      matlab.ui.control.Label
        ConnectorsEditField           matlab.ui.control.NumericEditField
        IndoorEditFieldLabel          matlab.ui.control.Label
        IndoorEditField               matlab.ui.control.NumericEditField
        OtherEditFieldLabel           matlab.ui.control.Label
        OtherEditField                matlab.ui.control.NumericEditField
        AntennaLabel                  matlab.ui.control.Label
        LossesLabel                   matlab.ui.control.Label
        ModelsTab                     matlab.ui.container.Tab
        GridLayout5                   matlab.ui.container.GridLayout
        DropDownModelPropagation      matlab.ui.control.DropDown
        DropDownCiudad                matlab.ui.control.DropDown
        DropDownZona                  matlab.ui.control.DropDown
        PropagationModelLabel         matlab.ui.control.Label
        CitySizeLabel                 matlab.ui.control.Label
        ZoneTypeLabel                 matlab.ui.control.Label
        DropDownEscenario             matlab.ui.control.DropDown
        LabelCondicion                matlab.ui.control.Label
        DropDownCondicion             matlab.ui.control.DropDown
        LabelModelo                   matlab.ui.control.Label
        DropDownModelo                matlab.ui.control.DropDown
        LabelEscenario                matlab.ui.control.Label
        ParametersLabel               matlab.ui.control.Label
        SimulateButton                matlab.ui.control.Button
        TabGroup2                     matlab.ui.container.TabGroup
        CoverageTab                   matlab.ui.container.Tab
        UIAxes                        matlab.ui.control.UIAxes
        GtxTab                        matlab.ui.container.Tab
        UIAxes2                       matlab.ui.control.UIAxes
        PowerTab                      matlab.ui.container.Tab
        UIAxes3                       matlab.ui.control.UIAxes
        GridLayout2                   matlab.ui.container.GridLayout
        AddAntennaButton              matlab.ui.control.Button
        DeleteAntennaButton           matlab.ui.control.Button
        MoveAntennaButton             matlab.ui.control.Button
        ResultingValuesTextAreaLabel  matlab.ui.control.Label
        ResultingValuesTextArea       matlab.ui.control.TextArea
        ContextMenu                   matlab.ui.container.ContextMenu
        Menu                          matlab.ui.container.Menu
        Menu2                         matlab.ui.container.Menu
    end

    
    properties (Access = private)
       
        isProgramStarted = false;
        dato_elev                % Datos de elevación
        rasterReference              % Referencia del raster
        meshX                        % Malla X
        meshY                        % Malla Y
        userElevation                % Elevación calculada
        isClickEnabled = false;      % Control para activar el click para crear antenas
        isDeleteEnabled = false;     % Para borrar antenas
        isMoveEnabled = false;       % Control para activar el modo de mover antenas
        antennaPositions = [];       % Para almacenar las posiciones de las antenas
        antennaHandles = {}          
        frecc = 900;                 % Frecuencia en MHz 
        h_tx = 40;                   % Altura de la antena base en metros
        h_rx = 1.5;                  % Altura de la antena móvil en metros
        Ptx = 42;                    % Potencia transmitida en dBm
        Gtx_max = 18;                % Ganancia de transmisión en dBi
        Grx = 0;                     % Ganancia de recepción en dBi
        Prx_min = -106;              % Límite de potencia recibida en dBm
        indoor = 20;
        conector = 2;
        otros = 2;
        L_conect = 0;
        modelopropag = 'Okumura Hata';  % Valor por defecto del modelo de propagación
        userPower
        processedAntennaCount = 0;    % Cuántas antenas ya fueron procesadas
        AntennaGraphicHandles = {}
        angulo_apertura = 120;          % Ángulo de apertura de la antena en grados
        tipo_ciudad = 'Suburbana';         % Tipo de área: 'urbana', 'suburbana' o 'abierta'
        tamano_ciudad = 'Grande';      % Tamaño de ciudad: 'grande' o 'mediana'
        
        % Asociado a 5G
        Modelo5G = 'CI'; % 'CI', 'CIF' o 'ABG'
        Escenario5G = 'UMA'; % 'UMA' o 'UMI'
        Condicion5G = 'LOS'; % 'LOS' o 'NLOS'
    end
    
    methods (Access = private)
        
        function [L_p] = modelo_okumura_hata(app, tipo_ciudad, tamano_ciudad, frecuencia, distancia, altura_antena, altura_usuario)
            %Verificación de parámetros de entrada para asegurar que están en los rangos correctos
            if frecuencia < 150 || frecuencia > 1000
                error('La frecuencia debe estar en el rango de 150 a 1000 MHz');
            end
            if altura_antena < 30 || altura_antena > 200
                error('La altura de la antena debe estar en el rango de 30 a 200 m');
            end
            if altura_usuario < 1 || altura_usuario > 10
                error('La altura del usuario debe estar en el rango de 1 a 10 m');
            end

            % Cálculo del factor de corrección de altura basado en el tamaño de la ciudad y frecuencia
            a_hm = factor_correccion(app, frecuencia, altura_usuario, tamano_ciudad);

            % Coeficientes A y B del modelo
            A = 69.55 + 26.16 * log10(frecuencia) - 13.82 * log10(altura_antena) - a_hm;
            B = 44.9 - 6.55 * log10(altura_antena);

            % Cálculo de coeficientes C y D para áreas suburbanas y abiertas
            C = 5.4 + 2 * (log10(frecuencia / 28))^2;
            D = 40.94 + 4.78 * (log10(frecuencia))^2 - 19.33 * log10(frecuencia);

            % Determinación de pérdidas L_p en función del tipo de ciudad
            switch tipo_ciudad
                case 'Urbana'
                    L_p = A + B * log10(distancia);
                case 'Suburbana'
                    L_p = A + B * log10(distancia) - C;
                case 'Rural'
                    L_p = A + B * log10(distancia) - D;
                otherwise
                    error('Tipo de ciudad no válido');
            end
        end

        function [factor_corr] = factor_correccion(app, f, h_user, tamano_ciudad)
            % Cálculo del factor de corrección en función del tamaño de la ciudad y la frecuencia
            if strcmp(tamano_ciudad, 'Grande')
                if f <= 200
                    factor_corr = 8.28 * (log10(1.54 * h_user))^2 - 1.1;
                elseif f >= 400
                    factor_corr = 3.2 * (log10(11.75 * h_user))^2 - 4.97;
                else
                    % Interpolación para frecuencias entre 200 y 400 MHz
                    factor_corr_200 = 8.28 * (log10(1.54 * h_user))^2 - 1.1;
                    factor_corr_400 = 3.2 * (log10(11.75 * h_user))^2 - 4.97;
                    factor_corr = factor_corr_200 + ((factor_corr_400 - factor_corr_200) / 200) * (f - 200);
                end
            else  % Para ciudades medianas o pequeñas
                factor_corr = (1.1 * log10(f) - 0.7) * h_user - (1.56 * log10(f) - 0.8);
            end
        end

%         function A_perdidas = calculo_de_Perdidas(app, tipo_ciudad, tamano_ciudad, frecuencia, distancia, altura_antena, altura_usuario)
%             
%             if strcmp(app.modelopropag, 'Okumura Hata')
%                 % Fórmula de Okumura-Hata para área urbana
%                 A_perdidas = modelo_okumura_hata(app, tipo_ciudad, tamano_ciudad, frecuencia, distancia, altura_antena, altura_usuario);
%                 
%             else
%                 % Free Space Path Loss (FSPL)
%                 %con nuestros parametros establecidos la distancia max
%                 %teorico es de 5375km, no se usara tal datos a diferentes
%                 %factores, uno de ellos los obstaculos, dispersion,
%                 %absorcion y reflexion que afectan la señal y Límite de
%                 %línea de vista (LOS) dLOS=3.57*(sqrt(ht)+sqrt(hr)) km
%                 %nos da una distancia de 27.5km teorico Sin embargo, en 
%                 % condiciones reales, factores como difracción y atenuación 
%                 % pueden reducir esto a 7-15 km
%                 max_distance_km = 8;
%                 distancia(distancia > max_distance_km) = NaN;
%                 A_perdidas = 32.45 + 20*log10(frecuencia) + 20*log10(distancia);  % Distancia en metros
%                 if distancia > max_distance_km
%                     A_perdidas = NaN;
%                 end
%             end
%         end
        
        function A_perdidas = calculo_de_Perdidas_Unificado(app, d_m)
            % Convertir unidades básicas
            distancia_km = d_m / 1000;
            f_mhz = app.FrequencyEditField.Value;
            
            % Verificar si el usuario seleccionó un modelo 5G
if strcmp(app.DropDownModelPropagation.Value, '6G Sub-THz')
                f_mhz_6g = app.FrequencyEditField.Value;
                f_ghz_6g = f_mhz_6g / 1000;
                if f_ghz_6g < 10 || all(d_m(:) < 1)
                    A_perdidas = NaN; return;
                end
                FSPL_1m_6g = 20*log10(4*pi*(f_mhz_6g*1e6)/3e8);
                esc_6g  = app.DropDownEscenario.Value;
                cond_6g = app.DropDownCondicion.Value;
                if strcmpi(esc_6g,'UMA')
                    if strcmpi(cond_6g,'LOS'), n_6g=2.0; else, n_6g=3.4; end
                else
                    if strcmpi(cond_6g,'LOS'), n_6g=2.1; else, n_6g=3.2; end
                end
                PL_spread_6g = FSPL_1m_6g + 10*n_6g*log10(d_m);
                picos_6g = [183.3,325.1,380.2,448.0,556.9,752.0];
                kpico_6g = [0.12,0.08,0.65,0.45,1.80,2.50];
                sig_6g   = [8.0,6.0,9.0,8.0,10.0,12.0];
                if f_ghz_6g<200, k_6g=5e-4; elseif f_ghz_6g<500, k_6g=3e-3; else, k_6g=8e-3; end
                for ii_6g=1:length(picos_6g)
                    k_6g = k_6g + kpico_6g(ii_6g)*exp(-((f_ghz_6g-picos_6g(ii_6g))^2)/(2*sig_6g(ii_6g)^2));
                end
                A_perdidas = PL_spread_6g + k_6g*d_m + 2.5;
            elseif strcmp(app.DropDownModelPropagation.Value, 'NYU 5G')                % --- LÓGICA NYU 5G ---
                params_5g = struct( ...
                    'UMA_LOS',  struct('G', 2.4, 'n', 2.0, 'A', 1.9, 'B', 35.8, 'C', 1.9), ...
                    'UMA_NLOS', struct('G', 5.3, 'n', 2.9, 'A', 3.5, 'B', 13.6, 'C', 2.4), ...
                    'UMI_LOS',  struct('G', 4.4, 'n', 2.1, 'A', 1.1, 'B', 46.8, 'C', 2.1), ...
                    'UMI_NLOS', struct('G', 7.1, 'n', 3.2, 'A', 2.8, 'B', 31.4, 'C', 2.7) ...
                );
                
               f_ghz = f_mhz / 1000; % NYU usa GHz
                
                % Evitar resultados erróneos por frecuencias irreales
                if f_ghz < 0.5
                    A_perdidas = NaN; 
                    return;
                end
                
                % Obtener valores actuales de los DropDowns
                esc = app.DropDownEscenario.Value;
                cond = app.DropDownCondicion.Value;
                mod5g = app.DropDownModelo.Value;
                
                clave = [upper(esc) '_' upper(cond)];
                p = params_5g.(clave);
                lambda = 3e8 / (f_ghz * 1e9);

                switch upper(mod5g)
                    case 'CI'
                        A_perdidas = p.G + 20*log10(4*pi/lambda) + 10*p.n*log10(d_m); 
                    case 'CIF'
                        A_perdidas = p.G + 20*log10(f_ghz) + 32.4 + 10*p.n*log10(d_m); 
                    case 'ABG'
                        A_perdidas = p.G + 10*p.A*log10(d_m) + p.B + 10*p.C*log10(f_ghz); 
                end
            else
                if strcmp(app.modelopropag, 'Okumura Hata')
                % --- LÓGICA 3G (Okumura-Hata) ---
                A_perdidas = app.modelo_okumura_hata(app.tipo_ciudad, app.tamano_ciudad, ...
                             f_mhz, distancia_km, app.h_tx, app.h_rx);
                else
                  A_perdidas = 32.45 + 20*log10(f_mhz) + 20*log10(distancia_km);
                end                    
            end
        end        
        
        
        function [d_max] = calcular_distancia_maxima(app, tipo_ciudad, L_max, f, h_tx, h_rx)
            % Parámetros base para el modelo de cálculo
            A = 69.55 + 26.16 * log10(f) - 13.82 * log10(h_tx) - factor_correccion(app, f, h_rx, 'mediana');
            B = 44.9 - 6.55 * log10(h_tx);

            % Determinar la distancia máxima en función del tipo de ciudad
            switch tipo_ciudad
                case 'Urbana'
                    d_max = 10^((L_max - A) / B);
                case 'Suburbana'
                    C = 5.4 + 2 * (log10(f / 28))^2;
                    d_max = 10^((L_max - A + C) / B);
                case 'Rural'
                    D = 40.94 + 4.78 * (log10(f))^2 - 19.33 * log10(f);
                    d_max = 10^((L_max - A + D) / B);
                otherwise
                    error('Tipo de ciudad no válido');
            end
        end


        function G = calcular_ganancia_antena_sectorizada(app, azimuth, elevation, angulo_apertura, G_0)
            % Calcular la ganancia de una antena sectorial en función de azimuth y elevación
            % azimuth: Ángulo de azimuth (phi) en grados
            % elevation: Ángulo de elevación (theta) en grados
            % angulo_apertura: Apertura del haz en el plano horizontal (phi_3) en grados
            % G_0: Ganancia máxima de la antena (dBi)

            % Parámetros base
            theta_3 = 107.6 * 10^(-0.1 * G_0);  % Ancho del haz a 3 dB en el plano vertical
            phi_3 = angulo_apertura;            % Ancho del haz a 3 dB en el plano horizontal

            % Normalización de los ángulos
            x_h = abs(azimuth) / phi_3;
            x_v = abs(elevation) / theta_3;

            % Parámetros de ajuste
            k_p = 0.7;
            k_v = 0.3;
            k_h = 0.7;
            x_k = sqrt(1 - (0.36 * k_v));
            G_180 = -12 + 10 * log10(1 + (8 * k_p)) - 15 * log10(180 / theta_3);
            C = (10 * log10(((180 / theta_3)^(1.5)) * ((4^(-1.5)) + k_v) / (1 + 8 * k_p))) / log10(22.5 / theta_3);
            lambda_kv = 12 - (C * log10(4)) - 10 * log10((4^(-1.5)) + k_v);
            lambda_kh = 3 * (1 - (0.5^(-k_h)));

            % Definición de ganancia en azimuth y elevación
            G_hr = @(x_h) (x_h <= 0.5) .* (-12 * x_h.^2) + ...
                (x_h > 0.5) .* (-12 * x_h.^(2 - k_h) - lambda_kh);

            G_vr = @(x_v) (x_v <= x_k) .* (-12 * x_v.^2) + ...
                (x_k <= x_v & x_v < 4) .* (-12 + 10 * log10((x_v.^-1.5) + k_v)) + ...
                (4 <= x_v & x_v < (90 / theta_3)) .* (-lambda_kv - C * log10(x_v)) + ...
                (x_v >= 90 / theta_3) .* G_180;

            % Evaluación de las ganancias horizontal y vertical
            G_hr_matrix = G_hr(x_h);
            G_vr_matrix = G_vr(x_v);

            % Relación de compresión para la ganancia horizontal
            R = (G_hr_matrix - G_hr(180 / phi_3)) / (G_hr(0) - G_hr(180 / phi_3));

            % Cálculo de la ganancia total
            G = G_0 + G_hr_matrix + R .* G_vr_matrix;
        end


        function azimuth_normalizado = calcular_azimuth(app, x, y, angulo_apertura, p_rb)
            % Cálculo del ángulo de azimuth desde la posición de la ERB
            azimuth_angles = atan2d(y - p_rb(2), x - p_rb(1));  % Ajusta según la posición de la ERB
            azimuth_angles = mod(azimuth_angles, 360);         % Ajuste al rango de 0 a 360 grados

            % Cálculo de los centros de cada sector para normalizar el azimuth
            num_sectores = 360 / angulo_apertura;
            centros_sectores = (0:angulo_apertura:360 - angulo_apertura)';

            % Inicialización del vector de azimuth normalizado
            azimuth_normalizado = nan(size(azimuth_angles));

            % Normalización del azimuth dentro de cada sector
            for i = 1:num_sectores
                centro_actual = centros_sectores(i);
                limite_inferior = centro_actual - angulo_apertura / 2;
                limite_superior = centro_actual + angulo_apertura / 2;

                % Ajuste para valores de azimuth en ciclo de 360 grados
                if limite_inferior < 0
                    indices_sector = azimuth_angles >= (360 + limite_inferior) | azimuth_angles <= limite_superior;
                elseif limite_superior > 360
                    indices_sector = azimuth_angles >= limite_inferior | azimuth_angles <= (limite_superior - 360);
                else
                    indices_sector = azimuth_angles >= limite_inferior & azimuth_angles <= limite_superior;
                end

                % Normalización al rango -apertura/2 a apertura/2
                azimuth_normalizado(indices_sector) = azimuth_angles(indices_sector) - centro_actual;
                azimuth_normalizado(indices_sector) = mod(azimuth_normalizado(indices_sector) + angulo_apertura / 2, angulo_apertura) - angulo_apertura / 2;
            end
        end

        
        function Pr_usuarios_antenna = calcularPrUsuarios(app, L_perdidas, Gtx)
            % Pr = Pt + Gt + Gr - Lp - Lt - Lr
            %Pr_usuarios_antenna = app.Ptx + app.Gtx_max + app.Grx - L_perdidas - app.L_c;
            Pr_usuarios_antenna = app.Ptx + Gtx + app.Grx - L_perdidas - app.L_conect;
            
            % Asignar NaN donde Pr < Pr_limit
            Pr_usuarios_antenna(Pr_usuarios_antenna < app.Prx_min) = NaN;
        end   
        
    end
            

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            
        % Establecer NYU 5G como selección por defecto al iniciar
        app.DropDownModelPropagation.Value = 'NYU 5G';
    
        % Llamar al callback para que se activen las visibilidades de los menús 5G
        app.DropDownModelPropagationValueChanged([]);   
        
        end

        % Value changed function: FrequencyEditField
        function FrequencyEditFieldValueChanged(app, event)
            app.frecc = app.FrequencyEditField.Value;

            % Función de alerta para frecuencia baja en 5G
        if strcmp(app.DropDownModelPropagation.Value, 'NYU 5G') && app.frecc < 1000
            uialert(app.UIFigure, ...
            ['Ha seleccionado NYU 5G con una frecuencia menor a 1 GHz. ' ...
             'Recuerde que estos modelos están optimizados para mmWave. ' ...
             'Se recomienda ingresar valores como 28000 (28 GHz).'], ...
            'Sugerencia Técnica', 'Icon', 'info');
        end           
            
        end

        % Value changed function: PtxEditField
        function PtxEditFieldValueChanged(app, event)
            app.Ptx = app.PtxEditField.Value;
        end

        % Value changed function: GananciaEditFieldTx
        function GananciaEditFieldTxValueChanged(app, event)
            app.Gtx_max = app.GananciaEditFieldTx.Value;
        end

        % Value changed function: GananciaEditField_Rx
        function GananciaEditField_RxValueChanged(app, event)
            app.Grx = app.GananciaEditField_Rx.Value;
        end

        % Value changed function: Prx_minEditField
        function Prx_minEditFieldValueChanged(app, event)
            app.Prx_min = app.Prx_minEditField.Value;
        end

        % Value changed function: HeightEditField
        function HeightEditFieldValueChanged(app, event)
            app.h_tx = app.HeightEditField.Value;
        end

        % Value changed function: OpeningAngleEditField
        function OpeningAngleEditFieldValueChanged(app, event)
            app.angulo_apertura = app.OpeningAngleEditField.Value;
        end

        % Value changed function: DropDownModelPropagation
        function DropDownModelPropagationValueChanged(app, event)
            Model = app.DropDownModelPropagation.Value;
            app.modelopropag = Model;
            
if strcmpi(Model, '6G Sub-THz')
                app.DropDownEscenario.Visible = 'on';
                app.DropDownCondicion.Visible = 'on';
                app.DropDownModelo.Visible    = 'off';
                app.LabelEscenario.Visible    = 'on';
                app.LabelCondicion.Visible    = 'on';
                app.LabelModelo.Visible       = 'off';
                app.ResultingValuesTextArea.Value = {'[6G Sub-THz] Ingrese frecuencia en MHz (ej: 140000 = 140 GHz).'};
            elseif strcmpi(Model, 'NYU 5G')                %app.Modelo5G = 'CI'; % Valor por defecto
                
                app.DropDownEscenario.Visible = 'on';
                app.DropDownCondicion.Visible = 'on';
                app.DropDownModelo.Visible = 'on';
                app.LabelEscenario.Visible = 'on';
                app.LabelCondicion.Visible = 'on';
                app.LabelModelo.Visible = 'on';
                
        
                % Forzar frecuencia a GHz en la lógica si es necesario
                app.ResultingValuesTextArea.Value = {'Modelo 5G NYU activado. Ingrese frecuencia en MHz.'};
            else
                % Ocultar si se elige Okumura u otro
                app.DropDownEscenario.Visible = 'off';
                app.DropDownCondicion.Visible = 'off';
                app.DropDownModelo.Visible = 'off';
                app.LabelEscenario.Visible = 'off';
                app.LabelCondicion.Visible = 'off';
                app.LabelModelo.Visible = 'off';
                
                if strcmpi(Model, 'Okumura Hata')
                    app.modelopropag = 'Okumura Hata';
                elseif strcmpi(Model, 'Walfish Ikegami')
                    app.modelopropag = 'Walfish Ikegami';
                else
                    app.modelopropag = 'Free Space Loss';
                end
            end
            
        end

        % Value changed function: DropDownCiudad
        function DropDownCiudadValueChanged(app, event)
            T_Ciudad = app.DropDownCiudad.Value;
            if strcmpi(T_Ciudad, 'Grande')
                app.tamano_ciudad = 'Grande';
            else
                app.tamano_ciudad = 'Mediano / Pequeño';
            end
        end

        % Value changed function: DropDownZona
        function DropDownZonaValueChanged(app, event)
            Zona = app.DropDownZona.Value;
            if strcmpi(Zona, 'Urbana')
                app.tipo_ciudad = 'Urbana';
            elseif strcmpi(Zona, 'Surbana')
                app.tipo_ciudad = 'Surbana';
            else
                app.tipo_ciudad = 'Rural';
            end
        end

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app, event)
            try   
                outputFile = fullfile('arequipa_ak.tif');
                % Pérdidas adicionales
                app.L_conect = app.indoor + app.conector + app.otros;
                                  
                [app.dato_elev, app.rasterReference] = readgeoraster(outputFile);
                app.dato_elev = double(app.dato_elev); 
                x = linspace(-25000, 25000, 200); 
                y = linspace(-25000, 25000, 200);  
                [app.meshX, app.meshY] = meshgrid(x, y);
                antenna_lat = -16.409444; % Latitud de Arequipa
                antenna_lon = -71.521944; % Longitud de Arequipa
      
                [latGrid, lonGrid] = geographicGrid(app.rasterReference);

                lat_users = antenna_lat + app.meshY / 111320;  % Latitud en grados
                lon_users = antenna_lon + app.meshX / (111320 * cosd(antenna_lat));  % Longitud en grados
                app.userElevation = interp2(lonGrid, latGrid, app.dato_elev, lon_users, lat_users, 'linear');

                nanMask = isnan(app.userElevation);
                if any(nanMask, 'all')
                    uialert(app.UIFigure, 'Algunas coordenadas están fuera del rango del DEM. Se han asignado valores de elevación como NaN.', 'Advertencia');
                end
                      
                surf(app.UIAxes, app.meshX/1000, app.meshY/1000, app.userElevation, 'EdgeColor', 'none', 'HitTest', 'off');  % Desactivar HitTest
                hold(app.UIAxes, 'on');
        
                % Ajustes de la visualización
                % xlim(app.UIAxes, [min(app.meshX(:))/1000 max(app.meshX(:))/1000]);
                % ylim(app.UIAxes, [min(app.meshY(:))/1000 max(app.meshY(:))/1000]);
                % zlim(app.UIAxes, [min(app.userElevation(:)) max(app.userElevation(:))]);
                axis(app.UIAxes, 'equal');      % Escalas iguales para X e Y
                view(app.UIAxes, 2); % Vista 2D
                       
                colormap(app.UIAxes, gray);  % Usar un colormap alternativo
                colorbar(app.UIAxes);
                title(app.UIAxes, 'Mapa de Elevación de Arequipa');
                xlabel(app.UIAxes, 'Distancia en X (km)');
                ylabel(app.UIAxes, 'Distancia en Y (km)');
                zlabel(app.UIAxes, 'Elevación del terreno (m)');
                app.isProgramStarted = true;   
                uialert(app.UIFigure, 'Los valores han sido simulados correctamente', 'Éxito', 'Icon','success');
        
            catch ME
                uialert(app.UIFigure, ['Error al iniciar el programa: ' ME.message], 'Error');
                disp(['Error al iniciar el programa: ', ME.message]);
            end
        end

        % Button pushed function: AddAntennaButton
        function AddAntennaButtonPushed(app, event)
            if app.isProgramStarted
                app.isClickEnabled = true;
                uialert(app.UIFigure, 'Seleccione la ubicación de la antena', 'Información', 'Icon', 'info');
            else
                uialert(app.UIFigure, 'Debe iniciar el programa primero haciendo clic en "Iniciar Programa".', 'Error', 'Icon', 'error');
            end
        end

        % Button down function: UIAxes
        function UIAxesButtonDown(app, event)
            if ~app.isProgramStarted
                uialert(app.UIFigure, 'Inicie el programa primero.', 'Error');
                return;
            end
            clickPos = event.IntersectionPoint; % [X, Y, Z]
            X_km = clickPos(1);
            Y_km = clickPos(2);
            Z_m = clickPos(3); % Altura de la antena
            
            if app.isClickEnabled
                % Modo agregar antena
                Z_antena = Z_m + app.h_tx;
                app.antennaPositions = [app.antennaPositions; X_km, Y_km, Z_antena];
                idxAntenna = size(app.antennaPositions, 1);
                % Mostrar resultados en el área de texto
                resultado = (['Antena agregada en X = ' num2str(X_km) ' km, Y = ' num2str(Y_km) ' km, con una elevación de ' num2str(Z_m) ' m']);
                app.ResultingValuesTextArea.Value = {resultado};

                % Graficar la antena
                hAntenna = plot3(app.UIAxes, X_km, Y_km, Z_m, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
                hText = text(app.UIAxes, X_km, Y_km + 3, Z_m + 7000, '', ...
                    'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'Margin', 4);
            
                coberturaHandles = gobjects(0); % Inicializar los handles de cobertura
            
                % Calcular y graficar la cobertura de la antena actual
                antena_pos_m = [X_km * 1000, Y_km * 1000]; % Convertir a metros
                
                distancia_euclidiana = sqrt((app.meshX - antena_pos_m(1)).^2 + (app.meshY - antena_pos_m(2)).^2 + ((app.userElevation + app.h_rx) - Z_antena).^2);
                
%                 L_perdidas = calculo_de_Perdidas(app, app.tipo_ciudad, app.tamano_ciudad, app.frecc, distancia_euclidiana/1000, app.h_tx, app.h_rx);
                L_perdidas = app.calculo_de_Perdidas_Unificado(distancia_euclidiana);
                L_max = app.Ptx + app.Gtx_max + app.Grx - app.Prx_min - app.L_conect;

                d_max = calcular_distancia_maxima(app, app.tipo_ciudad, L_max, app.frecc, app.h_tx, app.h_rx);

                azimuth = calcular_azimuth(app, app.meshX, app.meshY, app.angulo_apertura, antena_pos_m);
                
                angulo_depresion = atand((app.h_tx - app.h_rx) / (d_max * 1000));

                altura_ususarios = app.userElevation + app.h_rx;

                theta = zeros(size(distancia_euclidiana));

                for i = 1:size(distancia_euclidiana, 1)   % Recorre filas
                    for j = 1:size(distancia_euclidiana, 2)  % Recorre columnas
                        if altura_ususarios(i, j) < Z_antena
                            theta(i, j) = 90 - angulo_depresion - acosd((Z_antena - altura_ususarios(i, j)) / distancia_euclidiana(i, j));
                        elseif altura_ususarios(i, j) > Z_antena
                            theta(i, j) = - (angulo_depresion + asind((altura_ususarios(i, j) - Z_antena) / distancia_euclidiana(i, j)));
                        else
                            theta(i, j) = angulo_depresion;
                        end
                    end
                end
                

                Gtx = calcular_ganancia_antena_sectorizada(app, azimuth, theta, app.angulo_apertura, app.Gtx_max);

                Pr_usuarios_antenna = calcularPrUsuarios(app, L_perdidas, Gtx);
            
                % Normalizar y asignar colores
                min_Pr = min(Pr_usuarios_antenna(:));
                max_Pr = max(Pr_usuarios_antenna(:));
                if ~isnan(min_Pr) && ~isnan(max_Pr) && min_Pr < max_Pr
                    norm_Pr = (Pr_usuarios_antenna - min_Pr) / (max_Pr - min_Pr); % Normalización
                else
                    norm_Pr = NaN(size(Pr_usuarios_antenna)); % Manejar NaNs
                end

                % Seleccionar colormap (puedes cambiarlo por otros como 'viridis', 'parula', etc.)
                cmap = jet(256); % Colormap con 256 colores (puedes elegir otro como 'cool', 'parula', etc.)

                % Graficar los usuarios según la cobertura
                for i = 1:numel(app.meshX)
                    if ~isnan(Pr_usuarios_antenna(i)) % Asegúrate de no graficar valores NaN
                        % Obtener el color del colormap según el valor de norm_Pr
                        colorIndex = round(norm_Pr(i) * (size(cmap, 1) - 1)) + 1; % Normalizar para que el valor esté entre 1 y el número de colores
                        color = cmap(colorIndex, :); % Asignar el color basado en la normalización

                        % Graficar el punto 3D con el color correspondiente
                        h = plot3(app.UIAxes, app.meshX(i) / 1000, app.meshY(i) / 1000, app.userElevation(i), 'o', ...
                            'MarkerSize', 3, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none', 'HitTest', 'off');
                        coberturaHandles(end + 1) = h; % Agregar el handle a la lista
                    end
                end

                % Graficar la ganancia Gtx en app.UIAxes2                
                % Filtrar Gtx para usuarios válidos (Prx >= Prx_min)
                validIndices = ~isnan(Pr_usuarios_antenna); % Índices de usuarios válidos
                GtxValid = nan(size(Gtx)); % Crear una matriz con NaN para mantener dimensiones
                GtxValid(validIndices) = Gtx(validIndices); % Asignar valores válidos de Gtx
                
                % Graficar Gtx para usuarios válidos
                surf(app.UIAxes2, app.meshX / 1000, app.meshY / 1000, reshape(GtxValid, size(app.meshX)), 'EdgeColor', 'none'); % Ganancia en dBi
                hold(app.UIAxes2, 'on');
                title(app.UIAxes2, 'Ganancia de Transmisión (Gtx) - Usuarios Válidos');
                xlabel(app.UIAxes2, 'Distancia en X (km)');
                ylabel(app.UIAxes2, 'Distancia en Y (km)');
                zlabel(app.UIAxes2, 'Ganancia (dBi)');
                colormap(app.UIAxes2, jet);
                colorbar(app.UIAxes2);
                %Graficar la potencia de rx
                surf(app.UIAxes3, app.meshX / 1000, app.meshY / 1000, reshape(Pr_usuarios_antenna, size(app.meshX)), 'EdgeColor', 'none');

                % Guardar los handles de cobertura para la antena actual
                app.AntennaGraphicHandles{idxAntenna} = {hAntenna, hText, coberturaHandles};

                app.isClickEnabled = false; % Deshabilitar el modo de clic para agregar

            elseif app.isDeleteEnabled
                if isempty(app.antennaPositions)
                    uialert(app.UIFigure, 'No hay antenas para borrar.', 'Error');
                    app.isDeleteEnabled = false;
                    return;
                end
                
                % Encontrar la antena más cercana al clic
                X_ant = app.antennaPositions(:, 1);
                Y_ant = app.antennaPositions(:, 2);
                distancias = (X_ant - X_km).^2 + (Y_ant - Y_km).^2; 
                [~, idxMin] = min(distancias);
            
                H = app.AntennaGraphicHandles{idxMin};
                hAntenna = H{1};
                hText = H{2};
                coverageHandles = H{3};
            
                % Eliminar los objetos gráficos de la antena y cobertura
                if isvalid(hAntenna), delete(hAntenna); end
                if isvalid(hText), delete(hText); end
                for i = 1:length(coverageHandles)
                    if isvalid(coverageHandles(i)), delete(coverageHandles(i)); end
                end
                % Mostrar resultados en el área de texto
                app.ResultingValuesTextArea.Value = {''};
                    
             elseif app.isMoveEnabled
                % Modo mover antena
                if isempty(app.antennaPositions)
                    uialert(app.UIFigure, 'No seleccionó ninguna antena', 'Error');
                    return;
                end
        
                % Encontrar la antena más cercana al clic
                X_ant = app.antennaPositions(:, 1);
                Y_ant = app.antennaPositions(:, 2);
                distancias = (X_ant - X_km).^2 + (Y_ant - Y_km).^2;
                [~, idxMin] = min(distancias);
        
                if isempty(app.AntennaGraphicHandles{idxMin})
                    uialert(app.UIFigure, 'No se encontró la antena seleccionada', 'Error');
                    return;
                end
        
                % Eliminar gráficos actuales de la antena y su cobertura
                H = app.AntennaGraphicHandles{idxMin};
                hAntenna = H{1};
                hText = H{2};
                coverageHandles = H{3};
        
                if isvalid(hAntenna), delete(hAntenna); end
                if isvalid(hText), delete(hText); end
                for i = 1:length(coverageHandles)
                    if isvalid(coverageHandles(i)), delete(coverageHandles(i)); end
                end
        
                % Eliminar posición de la antena seleccionada
                app.antennaPositions(idxMin, :) = [];
                app.AntennaGraphicHandles(idxMin) = [];
        
                % Guardar la antena que se va a mover
                app.isMoveEnabled = false; % Desactivar el modo de selección
                app.isClickEnabled = true; % Activar modo para reposicionar
        
                uialert(app.UIFigure, 'Selecciona la nueva ubicación de la antena','Información', 'Icon', 'info');
            
            elseif app.isClickEnabled && ~isempty(app.antennaPositions)
                % Reposicionar la antena en la nueva ubicación
                Z_antena = Z_m + app.h_tx;
                app.antennaPositions = [app.antennaPositions; X_km, Y_km, Z_antena];
                idxAntenna = size(app.antennaPositions, 1);
        
                % Graficar la antena en la nueva posición
                hAntenna = plot3(app.UIAxes, X_km, Y_km, Z_m, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
                hText = text(app.UIAxes, X_km, Y_km + 3, Z_m + 7000, ['Antena ' num2str(idxAntenna)], ...
                    'Color', 'r', 'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'Margin', 4);
        
                coberturaHandles = gobjects(0); % Inicializar los handles de cobertura
        
                % Calcular y graficar la nueva cobertura
                antena_pos_m = [X_km * 1000, Y_km * 1000];
                distancia_euclidiana = sqrt((app.meshX - antena_pos_m(1)).^2 + ...
                    (app.meshY - antena_pos_m(2)).^2 + ((app.userElevation + app.h_rx) - Z_antena).^2);
                distancias_con_interferencia_km = distancia_euclidiana / 1000;
                L_perdidas = calculo_de_Perdidas(app, distancias_con_interferencia_km);
                Pr_usuarios_antenna = calcularPrUsuarios(app, L_perdidas);
        
                % Graficar los usuarios según la nueva cobertura
                for i = 1:numel(app.meshX)
                    if ~isnan(Pr_usuarios_antenna(i))
                        if Pr_usuarios_antenna(i) > app.powerLimit + 10
                            color = [1, 0, 0]; % Rojo
                        elseif Pr_usuarios_antenna(i) < app.powerLimit + 5
                            color = [1, 1, 0]; % Amarillo
                        else
                            color = [0, 1, 0]; % Verde
                        end
                        h = plot3(app.UIAxes, app.meshX(i) / 1000, app.meshY(i) / 1000, app.userElevation(i), ...
                           'o', 'MarkerSize', 3, 'MarkerFaceColor', color, 'MarkerEdgeColor', 'none');
                        coberturaHandles(end + 1) = h;
                    end
                end
        
                % Guardar los nuevos gráficos en los handles
                app.AntennaGraphicHandles{idxAntenna} = {hAntenna, hText, coberturaHandles};
        
                app.isClickEnabled = false; % Desactivar el modo de reposicionar
            end

        end

        % Button pushed function: DeleteAntennaButton
        function DeleteAntennaButtonPushed(app, event)
            if ~app.isProgramStarted
                uialert(app.UIFigure, 'Inicie el programa primero.', 'Error');
                return;
            end

            if isempty(app.antennaPositions)
                uialert(app.UIFigure, 'No hay antenas para borrar.', 'Error');
                return;
            end

            % Activar modo de borrado
            app.isDeleteEnabled = true;
            app.isClickEnabled = false;
            uialert(app.UIFigure, 'Selecciona la antena que desea eliminar', 'Información', 'Icon', 'info');
        end

        % Button pushed function: MoveAntennaButton
        function MoveAntennaButtonPushed(app, event)
            if ~app.isProgramStarted
                uialert(app.UIFigure, 'Inicie el programa primero.', 'Error');
                return;
            end

            if isempty(app.antennaPositions)
                uialert(app.UIFigure, 'No hay antenas para mover.', 'Error');
                return;
            end

            % Activar el modo de mover antenas
            app.isMoveEnabled = true;
            app.isClickEnabled = false;
            app.isDeleteEnabled = false;
            uialert(app.UIFigure, 'Selecciona la antena que quieres reposicionar','Información', 'Icon', 'info');
        end

        % Value changed function: ConnectorsEditField
        function ConnectorsEditFieldValueChanged(app, event)
            app.conector = app.ConnectorsEditField.Value;
        end

        % Value changed function: IndoorEditField
        function IndoorEditFieldValueChanged(app, event)
            app.indoor = app.IndoorEditField.Value;
        end

        % Value changed function: OtherEditField
        function OtherEditFieldValueChanged(app, event)
            app.otros = app.OtherEditField.Value;
        end

        % Value changed function: DropDownEscenario
        function DropDownEscenarioValueChanged(app, event)
            app.Escenario5G = app.DropDownEscenario.Value;
            
        end

        % Value changed function: DropDownCondicion
        function DropDownCondicionValueChanged(app, event)
            app.Condicion5G = app.DropDownCondicion.Value;
            
        end

        % Value changed function: DropDownModelo
        function DropDownModeloValueChanged(app, event)
            app.Modelo5G = app.DropDownModelo.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1216 632];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {0, '1x', '2x'};
            app.GridLayout.RowHeight = {'0.7x', '4.3x', '1x', '1x', 0, 0, 0, 0};

            % Create ResultingValuesTextArea
            app.ResultingValuesTextArea = uitextarea(app.GridLayout);
            app.ResultingValuesTextArea.Editable = 'off';
            app.ResultingValuesTextArea.HorizontalAlignment = 'center';
            app.ResultingValuesTextArea.Layout.Row = 4;
            app.ResultingValuesTextArea.Layout.Column = 3;

            % Create ResultingValuesTextAreaLabel
            app.ResultingValuesTextAreaLabel = uilabel(app.GridLayout);
            app.ResultingValuesTextAreaLabel.HorizontalAlignment = 'center';
            app.ResultingValuesTextAreaLabel.Layout.Row = 4;
            app.ResultingValuesTextAreaLabel.Layout.Column = 2;
            app.ResultingValuesTextAreaLabel.Text = 'Resulting Values';

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout2.RowHeight = {'1.5x'};
            app.GridLayout2.Layout.Row = 3;
            app.GridLayout2.Layout.Column = 3;

            % Create MoveAntennaButton
            app.MoveAntennaButton = uibutton(app.GridLayout2, 'push');
            app.MoveAntennaButton.ButtonPushedFcn = createCallbackFcn(app, @MoveAntennaButtonPushed, true);
            app.MoveAntennaButton.Layout.Row = 1;
            app.MoveAntennaButton.Layout.Column = 3;
            app.MoveAntennaButton.Text = 'Move Antenna';

            % Create DeleteAntennaButton
            app.DeleteAntennaButton = uibutton(app.GridLayout2, 'push');
            app.DeleteAntennaButton.ButtonPushedFcn = createCallbackFcn(app, @DeleteAntennaButtonPushed, true);
            app.DeleteAntennaButton.Layout.Row = 1;
            app.DeleteAntennaButton.Layout.Column = 2;
            app.DeleteAntennaButton.Text = 'Delete Antenna';

            % Create AddAntennaButton
            app.AddAntennaButton = uibutton(app.GridLayout2, 'push');
            app.AddAntennaButton.ButtonPushedFcn = createCallbackFcn(app, @AddAntennaButtonPushed, true);
            app.AddAntennaButton.Layout.Row = 1;
            app.AddAntennaButton.Layout.Column = 1;
            app.AddAntennaButton.Text = 'Add Antenna';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.GridLayout);
            app.TabGroup2.Layout.Row = 2;
            app.TabGroup2.Layout.Column = 3;

            % Create CoverageTab
            app.CoverageTab = uitab(app.TabGroup2);
            app.CoverageTab.Title = 'Coverage';

            % Create UIAxes
            app.UIAxes = uiaxes(app.CoverageTab);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.FontName = 'Book Antiqua';
            app.UIAxes.ButtonDownFcn = createCallbackFcn(app, @UIAxesButtonDown, true);
            app.UIAxes.Position = [17 22 599 296];

            % Create GtxTab
            app.GtxTab = uitab(app.TabGroup2);
            app.GtxTab.Title = 'Gain';

            % Create UIAxes2
            app.UIAxes2 = uiaxes(app.GtxTab);
            title(app.UIAxes2, 'Title')
            xlabel(app.UIAxes2, 'X')
            ylabel(app.UIAxes2, 'Y')
            zlabel(app.UIAxes2, 'Z')
            app.UIAxes2.FontName = 'Book Antiqua';
            app.UIAxes2.Position = [17 85 374 238];

            % Create PowerTab
            app.PowerTab = uitab(app.TabGroup2);
            app.PowerTab.Title = 'Power';

            % Create UIAxes3
            app.UIAxes3 = uiaxes(app.PowerTab);
            title(app.UIAxes3, 'Title')
            xlabel(app.UIAxes3, 'X')
            ylabel(app.UIAxes3, 'Y')
            zlabel(app.UIAxes3, 'Z')
            app.UIAxes3.FontName = 'Book Antiqua';
            app.UIAxes3.Position = [17 80 374 238];

            % Create SimulateButton
            app.SimulateButton = uibutton(app.GridLayout, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.Layout.Row = 3;
            app.SimulateButton.Layout.Column = 2;
            app.SimulateButton.Text = 'Simulate';

            % Create ParametersLabel
            app.ParametersLabel = uilabel(app.GridLayout);
            app.ParametersLabel.BackgroundColor = [0.8 0.8 0.8];
            app.ParametersLabel.HorizontalAlignment = 'center';
            app.ParametersLabel.Layout.Row = 1;
            app.ParametersLabel.Layout.Column = 2;
            app.ParametersLabel.Text = 'Parameters';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 2;
            app.TabGroup.Layout.Column = 2;

            % Create IntroductionTab
            app.IntroductionTab = uitab(app.TabGroup);
            app.IntroductionTab.Title = 'Introduction';

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.IntroductionTab);
            app.GridLayout6.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

            % Create IntegrantesGomezValderramaAnaLucilaLabel
            app.IntegrantesGomezValderramaAnaLucilaLabel = uilabel(app.GridLayout6);
            app.IntegrantesGomezValderramaAnaLucilaLabel.HorizontalAlignment = 'center';
            app.IntegrantesGomezValderramaAnaLucilaLabel.Layout.Row = [4 5];
            app.IntegrantesGomezValderramaAnaLucilaLabel.Layout.Column = [1 2];
            app.IntegrantesGomezValderramaAnaLucilaLabel.Text = {'Members:'; '- Moscoso Gutierrez, Maria Eugenia'; '-  Arizaca Huaranca, Danna Thais'; ''};

            % Create EsteproyectotienecomoobjetivoLabel
            app.EsteproyectotienecomoobjetivoLabel = uilabel(app.GridLayout6);
            app.EsteproyectotienecomoobjetivoLabel.HorizontalAlignment = 'center';
            app.EsteproyectotienecomoobjetivoLabel.WordWrap = 'on';
            app.EsteproyectotienecomoobjetivoLabel.Layout.Row = [1 3];
            app.EsteproyectotienecomoobjetivoLabel.Layout.Column = [1 2];
            app.EsteproyectotienecomoobjetivoLabel.Text = {'This program aims to calculate and visualize cellular coverage and link budgets for 3G, 4G, 5G, and 6G technologies in the Arequipa region of Peru.'; ''; 'By utilizing propagation models and region-specific, adjustable parameters, the program seeks to estimate signal range and quality across various areas based on the established conditions.'};

            % Create MediumTab
            app.MediumTab = uitab(app.TabGroup);
            app.MediumTab.Title = 'Medium';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.MediumTab);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', 1};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout3.ColumnSpacing = 0;
            app.GridLayout3.Padding = [0 10 0 10];

            % Create ReceptionLabel
            app.ReceptionLabel = uilabel(app.GridLayout3);
            app.ReceptionLabel.HorizontalAlignment = 'center';
            app.ReceptionLabel.Layout.Row = 5;
            app.ReceptionLabel.Layout.Column = [2 4];
            app.ReceptionLabel.Text = 'Reception';

            % Create TransmissionLabel
            app.TransmissionLabel = uilabel(app.GridLayout3);
            app.TransmissionLabel.HorizontalAlignment = 'center';
            app.TransmissionLabel.Layout.Row = 1;
            app.TransmissionLabel.Layout.Column = [2 4];
            app.TransmissionLabel.Text = 'Transmission';

            % Create Prx_minEditField
            app.Prx_minEditField = uieditfield(app.GridLayout3, 'numeric');
            app.Prx_minEditField.ValueChangedFcn = createCallbackFcn(app, @Prx_minEditFieldValueChanged, true);
            app.Prx_minEditField.Layout.Row = 7;
            app.Prx_minEditField.Layout.Column = [3 4];
            app.Prx_minEditField.Value = -106;

            % Create SensitivityLabel
            app.SensitivityLabel = uilabel(app.GridLayout3);
            app.SensitivityLabel.HorizontalAlignment = 'center';
            app.SensitivityLabel.Layout.Row = 7;
            app.SensitivityLabel.Layout.Column = [1 2];
            app.SensitivityLabel.Text = 'Sensitivity';

            % Create GananciaEditField_Rx
            app.GananciaEditField_Rx = uieditfield(app.GridLayout3, 'numeric');
            app.GananciaEditField_Rx.ValueChangedFcn = createCallbackFcn(app, @GananciaEditField_RxValueChanged, true);
            app.GananciaEditField_Rx.Layout.Row = 6;
            app.GananciaEditField_Rx.Layout.Column = [3 4];

            % Create GainLabel_2
            app.GainLabel_2 = uilabel(app.GridLayout3);
            app.GainLabel_2.HorizontalAlignment = 'center';
            app.GainLabel_2.Layout.Row = 6;
            app.GainLabel_2.Layout.Column = [1 2];
            app.GainLabel_2.Text = 'Gain';

            % Create GananciaEditFieldTx
            app.GananciaEditFieldTx = uieditfield(app.GridLayout3, 'numeric');
            app.GananciaEditFieldTx.ValueChangedFcn = createCallbackFcn(app, @GananciaEditFieldTxValueChanged, true);
            app.GananciaEditFieldTx.Layout.Row = 4;
            app.GananciaEditFieldTx.Layout.Column = [3 4];
            app.GananciaEditFieldTx.Value = 18;

            % Create GainLabel
            app.GainLabel = uilabel(app.GridLayout3);
            app.GainLabel.HorizontalAlignment = 'center';
            app.GainLabel.Layout.Row = 4;
            app.GainLabel.Layout.Column = [1 2];
            app.GainLabel.Text = 'Gain';

            % Create PtxEditField
            app.PtxEditField = uieditfield(app.GridLayout3, 'numeric');
            app.PtxEditField.ValueChangedFcn = createCallbackFcn(app, @PtxEditFieldValueChanged, true);
            app.PtxEditField.Layout.Row = 3;
            app.PtxEditField.Layout.Column = [3 4];
            app.PtxEditField.Value = 42;

            % Create PowerLabel
            app.PowerLabel = uilabel(app.GridLayout3);
            app.PowerLabel.HorizontalAlignment = 'center';
            app.PowerLabel.Layout.Row = 3;
            app.PowerLabel.Layout.Column = [1 2];
            app.PowerLabel.Text = 'Power';

            % Create FrequencyEditField
            app.FrequencyEditField = uieditfield(app.GridLayout3, 'numeric');
            app.FrequencyEditField.ValueChangedFcn = createCallbackFcn(app, @FrequencyEditFieldValueChanged, true);
            app.FrequencyEditField.Layout.Row = 2;
            app.FrequencyEditField.Layout.Column = [3 4];
            app.FrequencyEditField.Value = 900;

            % Create FrequencyEditFieldLabel
            app.FrequencyEditFieldLabel = uilabel(app.GridLayout3);
            app.FrequencyEditFieldLabel.HorizontalAlignment = 'center';
            app.FrequencyEditFieldLabel.Layout.Row = 2;
            app.FrequencyEditFieldLabel.Layout.Column = [1 2];
            app.FrequencyEditFieldLabel.Text = 'Frequency';

            % Create AntennaTab
            app.AntennaTab = uitab(app.TabGroup);
            app.AntennaTab.Title = 'Antenna';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.AntennaTab);
            app.GridLayout4.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout4.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};

            % Create LossesLabel
            app.LossesLabel = uilabel(app.GridLayout4);
            app.LossesLabel.HorizontalAlignment = 'center';
            app.LossesLabel.Layout.Row = 4;
            app.LossesLabel.Layout.Column = [2 4];
            app.LossesLabel.Text = 'Losses';

            % Create AntennaLabel
            app.AntennaLabel = uilabel(app.GridLayout4);
            app.AntennaLabel.HorizontalAlignment = 'center';
            app.AntennaLabel.Layout.Row = 1;
            app.AntennaLabel.Layout.Column = [2 4];
            app.AntennaLabel.Text = 'Antenna';

            % Create OtherEditField
            app.OtherEditField = uieditfield(app.GridLayout4, 'numeric');
            app.OtherEditField.ValueChangedFcn = createCallbackFcn(app, @OtherEditFieldValueChanged, true);
            app.OtherEditField.Layout.Row = 7;
            app.OtherEditField.Layout.Column = [3 4];
            app.OtherEditField.Value = 2;

            % Create OtherEditFieldLabel
            app.OtherEditFieldLabel = uilabel(app.GridLayout4);
            app.OtherEditFieldLabel.HorizontalAlignment = 'center';
            app.OtherEditFieldLabel.Layout.Row = 7;
            app.OtherEditFieldLabel.Layout.Column = [1 2];
            app.OtherEditFieldLabel.Text = 'Other';

            % Create IndoorEditField
            app.IndoorEditField = uieditfield(app.GridLayout4, 'numeric');
            app.IndoorEditField.ValueChangedFcn = createCallbackFcn(app, @IndoorEditFieldValueChanged, true);
            app.IndoorEditField.Layout.Row = 6;
            app.IndoorEditField.Layout.Column = [3 4];
            app.IndoorEditField.Value = 20;

            % Create IndoorEditFieldLabel
            app.IndoorEditFieldLabel = uilabel(app.GridLayout4);
            app.IndoorEditFieldLabel.HorizontalAlignment = 'center';
            app.IndoorEditFieldLabel.Layout.Row = 6;
            app.IndoorEditFieldLabel.Layout.Column = [1 2];
            app.IndoorEditFieldLabel.Text = 'Indoor';

            % Create ConnectorsEditField
            app.ConnectorsEditField = uieditfield(app.GridLayout4, 'numeric');
            app.ConnectorsEditField.ValueChangedFcn = createCallbackFcn(app, @ConnectorsEditFieldValueChanged, true);
            app.ConnectorsEditField.Layout.Row = 5;
            app.ConnectorsEditField.Layout.Column = [3 4];
            app.ConnectorsEditField.Value = 2;

            % Create ConnectorsEditFieldLabel
            app.ConnectorsEditFieldLabel = uilabel(app.GridLayout4);
            app.ConnectorsEditFieldLabel.HorizontalAlignment = 'center';
            app.ConnectorsEditFieldLabel.Layout.Row = 5;
            app.ConnectorsEditFieldLabel.Layout.Column = [1 2];
            app.ConnectorsEditFieldLabel.Text = 'Connectors';

            % Create OpeningAngleEditField
            app.OpeningAngleEditField = uieditfield(app.GridLayout4, 'numeric');
            app.OpeningAngleEditField.ValueChangedFcn = createCallbackFcn(app, @OpeningAngleEditFieldValueChanged, true);
            app.OpeningAngleEditField.Layout.Row = 3;
            app.OpeningAngleEditField.Layout.Column = [3 4];
            app.OpeningAngleEditField.Value = 120;

            % Create nguloAperturaLabel
            app.nguloAperturaLabel = uilabel(app.GridLayout4);
            app.nguloAperturaLabel.HorizontalAlignment = 'center';
            app.nguloAperturaLabel.WordWrap = 'on';
            app.nguloAperturaLabel.Layout.Row = 3;
            app.nguloAperturaLabel.Layout.Column = [1 2];
            app.nguloAperturaLabel.Text = 'Opening Angle';

            % Create HeightEditField
            app.HeightEditField = uieditfield(app.GridLayout4, 'numeric');
            app.HeightEditField.ValueChangedFcn = createCallbackFcn(app, @HeightEditFieldValueChanged, true);
            app.HeightEditField.Layout.Row = 2;
            app.HeightEditField.Layout.Column = [3 4];
            app.HeightEditField.Value = 40;

            % Create HeightEditFieldLabel
            app.HeightEditFieldLabel = uilabel(app.GridLayout4);
            app.HeightEditFieldLabel.HorizontalAlignment = 'center';
            app.HeightEditFieldLabel.Layout.Row = 2;
            app.HeightEditFieldLabel.Layout.Column = [1 2];
            app.HeightEditFieldLabel.Text = 'Height';

            % Create ModelsTab
            app.ModelsTab = uitab(app.TabGroup);
            app.ModelsTab.Title = 'Models';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.ModelsTab);
            app.GridLayout5.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout5.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x'};

            % Create LabelEscenario
            app.LabelEscenario = uilabel(app.GridLayout5);
            app.LabelEscenario.Layout.Row = 1;
            app.LabelEscenario.Layout.Column = 4;
            app.LabelEscenario.Text = 'Scenery';

            % Create DropDownModelo
            app.DropDownModelo = uidropdown(app.GridLayout5);
            app.DropDownModelo.Items = {'CI', 'CIF', 'ABG'};
            app.DropDownModelo.ValueChangedFcn = createCallbackFcn(app, @DropDownModeloValueChanged, true);
            app.DropDownModelo.Layout.Row = 6;
            app.DropDownModelo.Layout.Column = [4 5];
            app.DropDownModelo.Value = 'CI';

            % Create LabelModelo
            app.LabelModelo = uilabel(app.GridLayout5);
            app.LabelModelo.Layout.Row = 5;
            app.LabelModelo.Layout.Column = [4 5];
            app.LabelModelo.Text = 'Model';

            % Create DropDownCondicion
            app.DropDownCondicion = uidropdown(app.GridLayout5);
            app.DropDownCondicion.Items = {'LOS', 'NLOS'};
            app.DropDownCondicion.ValueChangedFcn = createCallbackFcn(app, @DropDownCondicionValueChanged, true);
            app.DropDownCondicion.Layout.Row = 4;
            app.DropDownCondicion.Layout.Column = [4 5];
            app.DropDownCondicion.Value = 'LOS';

            % Create LabelCondicion
            app.LabelCondicion = uilabel(app.GridLayout5);
            app.LabelCondicion.Layout.Row = 3;
            app.LabelCondicion.Layout.Column = [4 5];
            app.LabelCondicion.Text = 'Condition';

            % Create DropDownEscenario
            app.DropDownEscenario = uidropdown(app.GridLayout5);
            app.DropDownEscenario.Items = {'UMA', 'UMI'};
            app.DropDownEscenario.ValueChangedFcn = createCallbackFcn(app, @DropDownEscenarioValueChanged, true);
            app.DropDownEscenario.Layout.Row = 2;
            app.DropDownEscenario.Layout.Column = [4 5];
            app.DropDownEscenario.Value = 'UMA';

            % Create ZoneTypeLabel
            app.ZoneTypeLabel = uilabel(app.GridLayout5);
            app.ZoneTypeLabel.Layout.Row = 5;
            app.ZoneTypeLabel.Layout.Column = [1 3];
            app.ZoneTypeLabel.Text = 'Zone Type';

            % Create CitySizeLabel
            app.CitySizeLabel = uilabel(app.GridLayout5);
            app.CitySizeLabel.Layout.Row = 3;
            app.CitySizeLabel.Layout.Column = [1 3];
            app.CitySizeLabel.Text = 'City Size';

            % Create PropagationModelLabel
            app.PropagationModelLabel = uilabel(app.GridLayout5);
            app.PropagationModelLabel.Layout.Row = 1;
            app.PropagationModelLabel.Layout.Column = [1 3];
            app.PropagationModelLabel.Text = 'Propagation Model';

            % Create DropDownZona
            app.DropDownZona = uidropdown(app.GridLayout5);
            app.DropDownZona.Items = {'Urban', 'Suburban', 'Rural'};
            app.DropDownZona.ValueChangedFcn = createCallbackFcn(app, @DropDownZonaValueChanged, true);
            app.DropDownZona.Layout.Row = 6;
            app.DropDownZona.Layout.Column = [1 3];
            app.DropDownZona.Value = 'Urban';

            % Create DropDownCiudad
            app.DropDownCiudad = uidropdown(app.GridLayout5);
            app.DropDownCiudad.Items = {'Large', 'Medium / Small'};
            app.DropDownCiudad.ValueChangedFcn = createCallbackFcn(app, @DropDownCiudadValueChanged, true);
            app.DropDownCiudad.Layout.Row = 4;
            app.DropDownCiudad.Layout.Column = [1 3];
            app.DropDownCiudad.Value = 'Large';

            % Create DropDownModelPropagation
            app.DropDownModelPropagation = uidropdown(app.GridLayout5);
            app.DropDownModelPropagation.Items = {'NYU 5G', 'Okumura Hata', '6G Sub-THz'};
            app.DropDownModelPropagation.ValueChangedFcn = createCallbackFcn(app, @DropDownModelPropagationValueChanged, true);
            app.DropDownModelPropagation.Layout.Row = 2;
            app.DropDownModelPropagation.Layout.Column = [1 3];
            app.DropDownModelPropagation.Value = 'NYU 5G';

            % Create CellularCoverageandLinkBudgetLabel
            app.CellularCoverageandLinkBudgetLabel = uilabel(app.GridLayout);
            app.CellularCoverageandLinkBudgetLabel.HorizontalAlignment = 'center';
            app.CellularCoverageandLinkBudgetLabel.Layout.Row = 1;
            app.CellularCoverageandLinkBudgetLabel.Layout.Column = 3;
            app.CellularCoverageandLinkBudgetLabel.Text = 'Cellular Coverage and Link Budget';

            % Create ContextMenu
            app.ContextMenu = uicontextmenu(app.UIFigure);

            % Create Menu
            app.Menu = uimenu(app.ContextMenu);
            app.Menu.Text = 'Menu';

            % Create Menu2
            app.Menu2 = uimenu(app.ContextMenu);
            app.Menu2.Text = 'Menu2';
            
            % Assign app.ContextMenu
            app.DropDownModelPropagation.ContextMenu = app.ContextMenu;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Testex_6G_

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end