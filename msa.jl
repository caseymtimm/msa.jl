using Plots
using StatsPlots
using CSV
using Weave
using DataFrames
using Statistics

data = CSV.File("./testdata.csv") |> DataFrame

p = 5.15
α = 0.25

parts = unique(data.Part)
appraisers = unique(data.Appraiser)
trials = unique(data.Trial)

n = length(parts)
k = length(appraisers)
r = length(trials)

DFo = k - 1
DFp = n - 1
DFop = DFo * DFp
DFe = n * k * (r - 1)

grand_mean = mean(data.Value)

parts_means = map(x -> mean(x.Value), groupby(data, :Part))
operator_means = map(x -> mean(x.Value), groupby(data, :Appraiser))
trial_means = map(x -> mean(x.Value), groupby(data, :Trial))

SSo = n * r * sum(x -> (x - grand_mean)^2, operator_means)
SSp = k * r * sum(x -> (x - grand_mean)^2, parts_means)
SSe = sum(factor -> sum(x -> (x - mean(factor.Value))^2, factor.Value), groupby(data, [:Part, :Appraiser]))
TSS = sum(x -> (x - grand_mean)^2, data.Value)

SSop = TSS - (SSo + SSp + SSe)

MSo = SSo / DFo
MSp = SSp / DFp
MSop = SSop / DFop
MSe = SSe / DFe

τ² = MSe
γ² = (MSop - MSe) / r
ω² = (MSo - MSop) / (n * r)
σ² = (MSp - MSop) / (k * r)

EMSo = τ² - r * γ² + n * r * ω²
EMSp = τ² - r * γ² + k * r * σ²
EMSop = τ² - r * γ²
EMSe = τ²

f = MSop / MSe

anova_table = DataFrame(
    Source=["Appraiser", "Parts", "Appraiser x Part", "Gage (Error)"], 
    DF=[DFo, DFp, DFop, DFe],
    SS=[SSo, SSp, SSop, SSe],
    MS=[MSo, MSp, MSop, MSe],
    EMS=[EMSo, EMSp, EMSop, EMSe]
)

f_table = FDist(DFop, DFe)

critical_value = quantile(d, 1 - α)

significant = f > critical_value

equipment_variation = p * sqrt(MSe)
appraiser_variation = p * sqrt((MSo - MSop) / (n * r))
interaction = p * sqrt((MSop - MSe) / r)

RR = τ² + γ² + ω²

PV = p * sqrt((MSp - MSop) / (k * r))

TV = sqrt(RR^2 + PV^2)

precent_repeatability_variation = 100 * ((p * sqrt(τ²)) / (p * TV))

println(precent_repeatability_variation)

# weave("./GageWorksheet.jmd", doctype="pandoc2pdf", args=(data = data,))