import numpy as np

realizations = [
    [
        {"inflow": np.random.rand(24).tolist(), "price": np.random.rand(24).tolist()}
        for _ in range(2)
    ]
    for _ in range(7)
]