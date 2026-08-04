import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
import numpy as np
import os

# 1. Define the Hardware-Friendly MLP
class HardwareMLP(nn.Module):
    def __init__(self):
        super(HardwareMLP, self).__init__()
        # Layers perfectly divisible by 8
        self.fc1 = nn.Linear(784, 64)
        self.fc2 = nn.Linear(64, 32)
        self.fc3 = nn.Linear(32, 16) # 10 actual classes + 6 padded for hardware

    def forward(self, x):
        x = x.view(-1, 784)       # Flatten 28x28 image
        x = torch.relu(self.fc1(x))
        x = torch.relu(self.fc2(x))
        x = self.fc3(x)           # No activation on output layer
        return x

# 2. Helper function to convert integers to 8-bit Two's Complement Hex
def to_hex8(val):
    # Clamps value to 8-bit range [-128, 127] and converts to 2-digit hex
    val = int(max(min(val, 127), -128))
    return f"{(val & 0xFF):02X}"

def main():
    print("--- Downloading and Loading MNIST ---")
    transform = transforms.Compose([transforms.ToTensor()])
    trainset = torchvision.datasets.MNIST(root='./data', train=True, download=True, transform=transform)
    trainloader = torch.utils.data.DataLoader(trainset, batch_size=64, shuffle=True)

    model = HardwareMLP()
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)

    print("\n--- Training the Model (1 Epoch for demonstration) ---")
    model.train()
    for images, labels in trainloader:
        optimizer.zero_grad()
        outputs = model(images)
        
        # We only care about the first 10 outputs for the loss function
        # The remaining 6 nodes in the 16-node output layer will just naturally go to 0/noise
        loss = criterion(outputs[:, :10], labels)
        
        loss.backward()
        optimizer.step()
        
    print("Training Complete!")

    # 3. Quantization and Exporting to Hex
    print("\n--- Quantizing and Exporting Weights to .hex ---")
    os.makedirs("hex_files", exist_ok=True)
    
    # We use a simple scale factor to convert floats to 8-bit integers
    # In a real scenario, you'd calculate this based on the max weight value
    SCALE_FACTOR = 127.0 / 2.0 

    # Export Weights and Biases
    for name, param in model.named_parameters():
        filename = f"hex_files/{name.replace('.', '_')}.hex"
        
        # Multiply by scale and round to nearest integer
        quantized_tensor = torch.round(param.detach() * SCALE_FACTOR).numpy()
        
        with open(filename, "w") as f:
            # Flatten the tensor and write one hex value per line
            for val in quantized_tensor.flatten():
                f.write(to_hex8(val) + "\n")
                
        print(f"Exported: {filename} (Shape: {quantized_tensor.shape})")

    # 4. Export a Sample Image for Hardware Testing
    print("\n--- Exporting Sample Test Image ---")
    sample_image, sample_label = trainset[0]
    
    # Scale image pixels from [0.0, 1.0] float to [0, 127] int
    quantized_image = torch.round(sample_image * 127.0).numpy()
    
    with open("hex_files/sample_image.hex", "w") as f:
        for val in quantized_image.flatten():
            f.write(to_hex8(val) + "\n")
            
    print(f"Exported sample image (True Label: {sample_label}) to hex_files/sample_image.hex")
    print("\nDone! Your hex files are ready for SystemVerilog.")

if __name__ == "__main__":
    main()