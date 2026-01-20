
import os
import hydra
from omegaconf import DictConfig

@hydra.main(config_path="../configs", config_name="config")
def main(cfg: DictConfig):
    print("Starting Playback for Unitree G1...")
    
    # TODO: Load Environment in HEADLESS=False mode
    # env = G1DanceEnv(cfg, headless=False)
    
    # TODO: Load Policy
    # policy = load_checkpoint(cfg.checkpoint)
    
    # TODO: Loop
    # while True:
    #     obs = env.reset()
    #     action = policy(obs)
    #     env.step(action)

if __name__ == "__main__":
    main()
