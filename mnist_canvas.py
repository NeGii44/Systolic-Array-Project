import tkinter as tk
from PIL import Image, ImageDraw
import serial
import time

# --- Configuration ---
# You will need to change this to the COM port your ESP32-S3 is connected to (e.g., 'COM3' or '/dev/ttyUSB0')
SERIAL_PORT = 'COM3' 
BAUD_RATE = 115200

class MNISTCanvas:
    def __init__(self, root):
        self.root = root
        self.root.title("Edge AI MNIST Transmitter")
        
        # 1. Setup the Drawing Canvas (scaled up for easy drawing)
        self.canvas_width = 280
        self.canvas_height = 280
        self.canvas = tk.Canvas(self.root, width=self.canvas_width, height=self.canvas_height, bg='black')
        self.canvas.pack(pady=10)
        
        # Bind mouse events for drawing
        self.canvas.bind("<B1-Motion>", self.paint)
        
        # 2. Setup the PIL Image (happens in the background)
        # We create a black image and a drawing object to match the canvas
        self.image = Image.new("L", (self.canvas_width, self.canvas_height), "black")
        self.draw = ImageDraw.Draw(self.image)
        
        # 3. Buttons
        btn_frame = tk.Frame(self.root)
        btn_frame.pack(pady=5)
        
        tk.Button(btn_frame, text="Clear", command=self.clear_canvas, width=10).pack(side=tk.LEFT, padx=5)
        tk.Button(btn_frame, text="Send to ESP32", command=self.process_and_send, width=15).pack(side=tk.LEFT, padx=5)
        
        # 4. Setup Serial Connection
        try:
            self.ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
            print(f"Connected to ESP32 on {SERIAL_PORT} at {BAUD_RATE} baud.")
        except serial.SerialException:
            print(f"WARNING: Could not open {SERIAL_PORT}. Check your connection.")
            self.ser = None

    def paint(self, event):
        # Draw on the Tkinter canvas (visible to user)
        x1, y1 = (event.x - 10), (event.y - 10)
        x2, y2 = (event.x + 10), (event.y + 10)
        self.canvas.create_oval(x1, y1, x2, y2, fill="white", outline="white")
        
        # Draw on the hidden PIL image simultaneously
        self.draw.ellipse([x1, y1, x2, y2], fill="white")

    def clear_canvas(self):
        self.canvas.delete("all")
        self.image = Image.new("L", (self.canvas_width, self.canvas_height), "black")
        self.draw = ImageDraw.Draw(self.image)
        print("Canvas cleared.")

    def process_and_send(self):
        # Step A: Down-sample to exactly 28x28 pixels
        resized_img = self.image.resize((28, 28), Image.Resampling.LANCZOS)
        
        # Step B: Get pixel data (this returns a list of values from 0 to 255)
        pixel_data = list(resized_img.getdata())
        
        # Step C: Flatten to 1D array of 784 bytes (it's already a 1D list from getdata())
        byte_array = bytearray(pixel_data)
        
        print(f"Prepared {len(byte_array)} bytes of data.")
        
        # Step D: Transmit via UART
        if self.ser and self.ser.is_open:
            try:
                # Send a header byte so the ESP32 knows a new image is starting (optional but recommended)
                self.ser.write(b'\xAA') 
                time.sleep(0.01)
                
                # Send the 784 bytes of image data
                self.ser.write(byte_array)
                print("Data transmitted to ESP32 successfully!")
            except Exception as e:
                print(f"Error sending data: {e}")
        else:
            print("Cannot send: Serial port is not open. (Testing offline)")

if __name__ == "__main__":
    root = tk.Tk()
    app = MNISTCanvas(root)
    root.mainloop()