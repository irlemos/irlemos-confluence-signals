instrument {
    name = 'irlemos-confluence-signals',
    overlay = true
}

plot_text("Mensagem Condicional", 0, high[1] + 20, "white", "large", style.label_left)

-- Funcao para detectar maximas
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

-- Funcao para detectar minimas
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

-- Configuracoes de cor e largura de linha
input_group{"Color",
    color = input{default="white", type=input.color},
    width = input{default=1, type=input.line_width}
}

-- Identificao de maximas e minimas
local high_series = find_high()
local low_series = find_low()

hline(high_series, "High", color, high_width)
hline(low_series, "Low", color, width)

-- Linhas horizontais em intervalos diferentes
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

-- Configuracoes de medias moveis e MACD
MaFast_period = input(5, "Ma Fast period", input.integer, 1, 1000, 1)
MaSlow_period = input(20, "Ma Slow period", input.integer, 1, 1000, 1)
Signal_period = input(12, "Signal period", input.integer, 1, 1000, 1)

-- Calculo do MACD
local macd_line = ema(close, MaFast_period) - ema(close, MaSlow_period)
local signal_line = ema(macd_line, Signal_period)

-- Condicoes de compra e venda baseadas no MACD
local buyCondition = macd_line > signal_line and macd_line[1] <= signal_line[1]
local sellCondition = macd_line < signal_line and macd_line[1] >= signal_line[1]

-- Plotagem dos sinais de compra e venda
plot_shape(buyCondition, "COMPRAR", shape_style.triangleup, shape_size.huge, "green", shape_location.belowbar, -1, "COMPRAR", "white")
plot_shape(sellCondition, "VENDER", shape_style.triangledown, shape_size.huge, "red", shape_location.abovebar, -1, "VENDER", "white")

-- Configuraes de niveis de suporte e resistencia
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

-- Funcao para analisar candles de 15 minutos
local function analyze_candle(candle)
    c1 = candle.high
    c2 = candle.low
end

-- Resolucao de 15 minutos
local resolution = "15m"
local sec = security(current_ticker_id, resolution)

if sec then
    analyze_candle(sec)
    plot(c1, "C1", level_1_color, level_1_width, 0, style.levels, na_mode.continue)
    plot(c2, "C2", level_2_color, level_2_width, 0, style.levels, na_mode.continue)
end
