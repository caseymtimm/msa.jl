using Test
using MSA
using CSV
using DataFrames

data = CSV.File("./testdata.csv") |> DataFrame

p = 5.15
α = 0.25

anova, τ², γ², ω², σ², RR, TV, significant, precent_study_variation, precent_contribution = gage(data, p, α)

@testset "Anova Table" begin
    @testset "Degrees of Freedom (DF)" begin
        @test round(anova.DF.o, digits=5) == 2
        @test round(anova.DF.p, digits=5) == 9
        @test round(anova.DF.op, digits=5) == 18
        @test round(anova.DF.e, digits=5) == 30
    end
    @testset "Sum Of Squares (SS)" begin
        @test round(anova.SS.o, digits=5) == 0.04800
        @test round(anova.SS.p, digits=5) == 2.05871
        @test round(anova.SS.op, digits=5) == 0.10367
        @test round(anova.SS.e, digits=5) == 0.03875
    end
    @testset "Means Squared (MS)" begin
        @test round(anova.MS.o, digits=5) == 0.02400
        @test round(anova.MS.p, digits=5) == 0.22875
        @test round(anova.MS.op, digits=5) == 0.00576 # This is really 0.00575 in the book but rounds to 0.00576
        @test round(anova.MS.e, digits=5) == 0.00129
    end
    @test round(anova.f, digits=2) == 4.46 # This is 4.45 in the book, but is really 4.4588
end

@testset "Results" begin
    @test round(TV, digits=2) == 1.05
    @testset "Estimate of Variance" begin
        @test round(τ², digits=5) == 0.00129
        @test round(γ², digits=5) == 0.00223
        @test round(ω², digits=5) == 0.00091
        @test round(σ², digits=7) == 0.0371644 # The book has 0.0371641 but I get 0.0371644 is this a rounding error?
        @test round(RR, digits=5) == 0.00443
    end
    @testset "% Study Variation" begin
        @test round(precent_study_variation.repeatability, digits=1) == 17.6
        @test round(precent_study_variation.operator, digits=1) == 14.8
        @test round(precent_study_variation.interaction, digits=1) == 23.2
        @test round(precent_study_variation.rr, digits=1) == 32.7
        @test round(precent_study_variation.part, digits=1) == 94.5
    end
    @testset "% Contribution" begin
        @test round(precent_contribution.repeatability, digits=1) == 3.1
        @test round(precent_contribution.operator, digits=1) == 2.2
        @test round(precent_contribution.interaction, digits=1) == 5.4
        @test round(precent_contribution.rr, digits=1) == 10.7
        @test round(precent_contribution.part, digits=1) == 89.3
    end
end

# weave("./GageWorksheet.jmd", doctype="pandoc2pdf", args=(data = data,))