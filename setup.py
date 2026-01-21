from setuptools import setup, find_packages

setup(
    name="unitree_rl",
    version="0.1.0",
    packages=find_packages(),
    install_requires=[
        "torch",
        "numpy",
        "hydra-core",
        "params-proto==2.10.5",
        "tqdm",
        "matplotlib",
    ],
    author="GXMZUAILAB",
    description="Reinforcement Learning for Unitree G1 Humanoid Robot",
    python_requires=">=3.10",
)
