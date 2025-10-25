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
-- tempo gráfico superior (padrão de 15 minutos) para uma análise de contexto
-- mais ampla. Além disso este indicador combina um filtro de tendência (MME 200)
-- com os cruzamentos do MACD para gerar sinais visuais de alta e baixa probabilidade.
--
-- FUNCIONALIDADES:
-- 1. Sinais de Compra/Venda baseados no cruzamento do MACD.
-- 2. Sinais de Compra/Venda baseados no cruzamento do MACD a favor da tendência.
-- 3. Plotagem de topos e fundos locais.
-- 4. Múltiplas linhas de suporte/resistência (HH/LL de 10 a 200 períodos).
-- 5. Análise de máximas e mínimas do tempo gráfico de 15 minutos.
--
-- -----------------------------------------------------------------------------


-- SEÇÃO 1: CONFIGURAÇÕES INICIAIS

-- Define o nome do indicador e especifica que ele deve ser plotado
-- sobre o gráfico de preços principal (overlay = true).
instrument {
    name = 'irlemos-confluence-signals',
    overlay = true
}


-- SEÇÃO 2: CONFIGURAÇÕES DO USUÁRIO

input_group{"Color", color = input{default="white", type=input.color}, width = input{default=1, type=input.line_width}}
MaFast_period = input(12, "Ma Fast period", input.integer, 1, 1000, 1)
MaSlow_period = input(26, "Ma Slow period", input.integer, 1, 1000, 1)
Signal_period = input(9, "Signal period", input.integer, 1, 1000, 1)
MaTrend_period = input(200, "Trend Filter MA period", input.integer, 1, 1000, 1)

-- SEÇÃO 3: CÁLCULOS DOS INDICADORES
local macd_line = ema(close, MaFast_period) - ema(close, MaSlow_period)
local signal_line = ema(macd_line, Signal_period)
local trend_ma = ema(close, MaTrend_period)


-- SEÇÃO 4: PLOTAGEM DAS LINHAS DE REFERÊNCIA

plot(trend_ma, "Trend MA", "blue", 2)
hline(highest(10)[1], "HH10", color, 1); hline(lowest(10)[1], "LL10", color, 1)
hline(highest(30)[1], "HH30", color, 1); hline(lowest(30)[1], "LL30", color, 1)
hline(highest(60)[1], "HH60", color, 1); hline(lowest(60)[1], "LL60", color, 1)
hline(highest(100)[1], "HH100", color, 1); hline(lowest(100)[1], "LL100", color, 1)
hline(highest(150)[1], "HH150", color, 1); hline(lowest(150)[1], "LL150", color, 1)
hline(highest(200)[1], "HH200", color, 1); hline(lowest(200)[1], "LL200", color, 1)


-- SEÇÃO 5: LÓGICA DE SINAIS E PLOTAGEM VISUAL

local buyCondition = macd_line > signal_line and macd_line[1] <= signal_line[1]
local sellCondition = macd_line < signal_line and macd_line[1] >= signal_line[1]

-- Condições de Confluência (Sinais Fortes)
local strongBuyCondition = buyCondition and close > trend_ma
local strongSellCondition = sellCondition and close < trend_ma

-- Condições Normais (Sinais Fracos ou Contra a Tendência)
local normalBuyCondition = buyCondition and not strongBuyCondition
local normalSellCondition = sellCondition and not strongSellCondition

-- Plotagem dos Sinais Fortes
plot_shape(strongBuyCondition, "compra-sinal-forte", shape_style.triangleup, shape_size.huge, "lime", shape_location.belowbar, -1, "", "white")
plot_shape(strongSellCondition, "venda-sinal-forte", shape_style.triangledown, shape_size.huge, "fuchsia", shape_location.abovebar, -1, "", "white")

-- Plotagem dos Sinais Normais
plot_shape(normalBuyCondition, "compra-normal", shape_style.triangleup, shape_size.normal, "green", shape_location.belowbar, -1, "", "white")
plot_shape(normalSellCondition, "venda-normal", shape_style.triangledown, shape_size.normal, "red", shape_location.abovebar, -1, "", "white")


-- SEÇÃO 6: ANÁLISE DE MÚLTIPLOS TEMPOS GRÁFICOS (MTF)

input_group { "Maxima (15m)", level_1_color = input { default = "red", type = input.color }, level_1_width = input { default = 2, type = input.line_width } }
input_group { "Minima (15m)", level_2_color = input { default = "green", type = input.color }, level_2_width = input { default = 2, type = input.line_width } }

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
    plot(c1, "Max 15m", level_1_color, level_1_width, 0, style.levels, na_mode.continue)
    -- Plota a mínima da vela como uma linha de suporte.
    plot(c2, "Min 15m", level_2_color, level_2_width, 0, style.levels, na_mode.continue)
end
