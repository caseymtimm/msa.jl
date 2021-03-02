module MSA

using DataFrames
using Statistics
using Distributions

export gage

function gage(data, p, α)
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

    anova = (
        DF = (o = DFo, p = DFp, op = DFop, e = DFe),
        SS = (o = SSo, p = SSp, op = SSop, e = SSe),
        MS = (o = MSo, p = MSp, op = MSop, e = MSe),
        EMS = (o = EMSo, p = EMSp, op = EMSop, e = EMSe),
        f = f
    )

    f_table = FDist(DFop, DFe)

    critical_value = quantile(f_table, 1 - α)

    significant = f > critical_value

    equipment_variation = p * sqrt(MSe)
    appraiser_variation = p * sqrt((MSo - MSop) / (n * r))
    interaction = p * sqrt((MSop - MSe) / r)

    RR = τ² + γ² + ω²

    PV = p * sqrt(σ²)

    TV = sqrt((p * sqrt(RR))^2 + PV^2)

    precent_study_variation = (
        repeatability = 100 * (p * sqrt(τ²) / TV),
        operator = 100 * (p * sqrt(ω²) / TV),
        interaction = 100 * (p * sqrt(γ²) / TV),
        rr = 100 * (p * sqrt(RR) / TV),
        part = 100 * (p * sqrt(σ²) / TV),
    ) 

    precent_contribution = (
        repeatability = 100 * (p * sqrt(τ²) / TV)^2,
        operator = 100 * (p * sqrt(ω²) / TV)^2,
        interaction = 100 * (p * sqrt(γ²) / TV)^2,
        rr = 100 * (p * sqrt(RR) / TV)^2,
        part = 100 * (p * sqrt(σ²) / TV)^2,
    ) 



    anova, τ², γ², ω², σ², RR, TV, significant, precent_study_variation, precent_contribution

end

end
