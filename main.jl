using SDDP, HiGHS, DataFrames
realizations = [
    [(; inflow = rand(24), price = rand(24)) for _ in 1:2]
    for t in 1:7
];
model = SDDP.LinearPolicyGraph(
    stages = 7,
    upper_bound = 7 * 24,
    sense = :Max,
    optimizer = HiGHS.Optimizer,
) do sp, stage
    @variable(sp, 0 <= x_weekly_volume <= 1, SDDP.State, initial_value = 1)
    @variable(sp, 0 <= u_volume[1:24] <= 1)
    @variable(sp, u_discharge[1:24] >= 0)
    @variable(sp, u_spill[1:24] >= 0)
    @variable(sp, u_inflow[1:24])
    @constraint(sp, [h in 1:24],
        u_volume[h] == (h == 1 ? x_weekly_volume.in : u_volume[h-1]) +
            u_inflow[h] - u_discharge[h] - u_spill[h]
    )
    @constraint(sp, x_weekly_volume.out == u_volume[24])
    SDDP.parameterize(sp, realizations[stage]) do w
        fix.(u_inflow, w.inflow)
        @stageobjective(sp, sum(w.price .* u_discharge))
    end
end
SDDP.train(model)
