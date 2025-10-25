-- -----------------------------------------------------------------------------
--
-- AUTOR: Rodrigo Lemos Del Poço
-- PROJETO: irlemos-confluence-signals
-- PLATAFORMA: Plataformas baseadas em Quadcode
-- LINGUAGEM: Quadcode Script (baseado em Lua)
--
-- DESCRIÇÃO:
-- Este indicador para plataformas Quadcode foi projetado para fornecer uma
-- análise de confluência, combinando múltiplos sinais técnicos em um único
-- gráfico. Ele utiliza o indicador MACD para gerar sinais de compra e venda,
-- plotamúltiplos níveis de suporte e resistência, e incorpora dados de um
-- tempo gráfico superior (15 minutos) para uma análise de contexto mais ampla.
--
-- FUNCIONALIDADES:
-- 1. Sinais de Compra/Venda baseados no cruzamento do MACD.
-- 2. Plotagem de topos e fundos locais.
-- 3. Múltiplas linhas de suporte/resistência (HH/LL de 10 a 200 períodos).
-- 4. Análise de máximas e mínimas do tempo gráfico de 15 minutos.
-- -----------------------------------------------------------------------------


-- SEÇÃO 1: CONFIGURAÇÕES INICIAIS

-- Define o nome do indicador e especifica que ele deve ser plotado
-- sobre o gráfico de preços principal (overlay = true).
instrument {
    name = 'irlemos-confluence-signals',
    overlay = true
}


-- SEÇÃO 2: ELEMENTOS VISUAIS NO GRÁFICO

-- Plota um texto estático no gráfico. Esta linha pode ser expandida
-- com lógica condicional para exibir mensagens dinâmicas.
plot_text("Mensagem Condicional", 0, high[1] + 20, "white", "large", style.label_left)


-- SEÇÃO 3: FUNÇÕES PARA DETECÇÃO DE TOPOS E FUNDOS LOCAIS

-- Função para detectar máximas
-- Uma máxima é identificada se a vela de 2 períodos atrás (high[2]) for maior
-- que as duas velas anteriores e as duas velas posteriores.
local function find_high()
    local high_series = make_series()
    local high_value = high[2]

    if not get_value(high_value) then 
        return high_series 
    end

    local is_high = high <= high_value and high[1] <= high_value and high[3] <= high_value and high[4] <= high_value
    high_series:set(iff(is_high, high_value, high_series[1]))

    return high_series
end

-- Função para detectar mínimas
-- Uma mínima é identificada se a vela de 2 períodos atrás (low[2]) for menor
-- que as duas velas anteriores e as duas velas posteriores.
local function find_low()
    local low_series = make_series()
    local low_value = low[2]

    if not get_value(low_value) then 
        return low_series 
    end

    local is_low = low >= low_value and low[1] >= low_value and low[3] >= low_value and low[4] >= low_value
    low_series:set(iff(is_low, low_value, low_series[1]))

    return low_series
end


-- SEÇÃO 4: ENTRADAS DO USUÁRIO (INPUTS) PARA CONFIGURAÇÃO VISUAL

-- Configurações de cor e largura para as linhas de máximas e mínimas
input_group{"Color",
    color = input{default="white", type=input.color},
    width = input{default=1, type=input.line_width}
}


-- SEÇÃO 5: EXECUÇÃO DAS FUNÇÕES E PLOTAGEM DOS NÍVEIS DE TOPOS/FUNDOS

-- Identificação e armazenamento das máximas e mínimas encontradas
local high_series = find_high()
local low_series = find_low()

-- Plotagem das linhas horizontais nas máximas e mínimas identificadas
hline(high_series, "High", color, high_width)
hline(low_series, "Low", color, width)


-- SEÇÃO 6: PLOTAGEM DE NÍVEIS DE SUPORTE E RESISTÊNCIA HISTÓRICOS (HH & LL)

-- Plota linhas horizontais nos preços mais altos (Highest High - HH) e mais baixos
-- (Lowest Low - LL) em diferentes períodos de tempo (10, 30, 60, 100, 150, 200).
hline(highest(10)[1], "HH10", color, 1)
hline(lowest(10)[1], "LL10", color, 1)
hline(highest(30)[1], "HH30", color, 1)
hline(lowest(30)[1], "LL30", color, 1)
hline(highest(60)[1], "HH60", color, 1)
hline(lowest(60)[1], "LL60", color, 1)
hline(highest(100)[1], "HH100", color, 1)
hline(lowest(100)[1], "LL100", color, 1)
hline(highest(150)[1], "HH150", color, 1)
hline(lowest(150)[1], "LL150", color, 1)
hline(highest(200)[1], "HH200", color, 1)
hline(lowest(200)[1], "LL200", color, 1)


-- SEÇÃO 7: CONFIGURAÇÃO E CÁLCULO DO INDICADOR MACD

-- Configurações do usuário para os períodos das médias móveis do MACD
MaFast_period = input(5, "Ma Fast period", input.integer, 1, 1000, 1)
MaSlow_period = input(20, "Ma Slow period", input.integer, 1, 1000, 1)
Signal_period = input(12, "Signal period", input.integer, 1, 1000, 1)

-- Calculo das linhas do MACD
local macd_line = ema(close, MaFast_period) - ema(close, MaSlow_period)
local signal_line = ema(macd_line, Signal_period)


-- SEÇÃO 8: LÓGICA E PLOTAGEM DOS SINAIS DE COMPRA E VENDA

-- Condição de Compra: A linha MACD cruza para CIMA da linha de Sinal
local buyCondition = macd_line > signal_line and macd_line[1] <= signal_line[1]
-- Condição de Venda: A linha MACD cruza para BAIXO da linha de Sinal
local sellCondition = macd_line < signal_line and macd_line[1] >= signal_line[1]

-- Plotagem dos sinais visuais no gráfico
-- Plota um triângulo verde abaixo da vela quando a condição de compra é atendida.
plot_shape(buyCondition, "COMPRAR", shape_style.triangleup, shape_size.huge, "green", shape_location.belowbar, -1, "COMPRAR", "white")
-- Plota um triângulo vermelho acima da vela quando a condição de venda é atendida.
plot_shape(sellCondition, "VENDER", shape_style.triangledown, shape_size.huge, "red", shape_location.abovebar, -1, "VENDER", "white")


-- SEÇÃO 9: ANÁLISE DE MÚLTIPLOS TEMPOS GRÁFICOS (MTF)

-- Configurações do usuário para a cor e largura dos níveis de 15 minutos
input_group {
    "Maxima",
    level_1_color = input { default = "red", type = input.color },
    level_1_width = input { default = 2, type = input.line_width }
}

input_group {
    "Minima",
    level_2_color = input { default = "green", type = input.color },
    level_2_width = input { default = 2, type = input.line_width }
}

-- Função para extrair dados da vela de um tempo gráfico superior
-- Esta função armazena os valores de máxima e mínima da vela.
local function analyze_candle(candle)
    c1 = candle.high
    c2 = candle.low
end

-- Configuração da resolução  de tempo as ser avaliada, padrão de 15 minutos
local resolution = "15m"
-- A função 'security' busca dados do ativo atual ("current_ticker_id")
-- de acordo com a resolução de tempo definida
local sec = security(current_ticker_id, resolution)

-- Execução da análise e plotagem dos níveis de acordo com a relosução indicada
if sec then
    -- Se os dados foram carregados com sucesso, chama a função para extrair a máxima e a mínima.
    analyze_candle(sec)
    -- Plota a máxima da vela como uma linha de resistência.
    plot(c1, "C1", level_1_color, level_1_width, 0, style.levels, na_mode.continue)
    -- Plota a mínima da vela como uma linha de suporte.
    plot(c2, "C2", level_2_color, level_2_width, 0, style.levels, na_mode.continue)
end
