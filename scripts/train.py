
import os
import hydra
from omegaconf import DictConfig, OmegaConf

@hydra.main(config_path="../configs", config_name="config")
def main(cfg: DictConfig):
    print(OmegaConf.to_yaml(cfg))
    print("Starting Training for Unitree G1...")
    
    # TODO: Load Environment
    # env = G1DanceEnv(cfg)
    
    # TODO: Initialize PPO Runner
    # runner = PPO(env, cfg)
    # runner.learn()

if __name__ == "__main__":
    main()
