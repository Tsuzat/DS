from fastapi import FastAPI, Request
import numpy as np
from PIL import Image
from uvicorn import run

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.post("/svd")
async def svd(response: Request):
    data = await response.json()
    img_paths = data["img_paths"]
    left_proj, right_proj = svd_image(img_paths)
    # convert numpy array to list
    left_proj = left_proj.tolist()
    right_proj = right_proj.tolist()
    return {"left": left_proj, "right": right_proj}


# Function which takes image path as input and returns the SVD of the image using numpy
def svd_image(image_path):

    # Load the image into a NumPy array
    img = np.array(Image.open(image_path).convert('L'))
    # Compute the SVD of the image
    U, _, Vt = np.linalg.svd(img)
    # print(U)
    # print(Vt.T)
    # Transpose of img
    imgT = img.T

    # left vector is the 2nd column of U
    left_vec = U[:, 1]
    # right vector is the 2nd row of Vt
    right_vec = Vt[1, :]
    # Taking the left projection left_proj = imgT * U
    left_proj = imgT @ left_vec
    # Taking the right projection right_proj is matrix multiplication of img and Vt
    right_proj = img @ right_vec
    return left_proj, right_proj


if __name__ == "__main__":
    run(app, host="127.0.0.1", port=8000, reload=False)
