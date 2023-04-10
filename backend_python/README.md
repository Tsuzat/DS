## Backend For the DLDS written in python

The backend for DLDS is written in python which used `fastapi` to handle the requests and `uvicorn` to run the server.

`numpy` has been used for **SVD** calculation. `pillow` has been used for image processing.

### Installation

If you wish to run the backend locally, you can install the dependencies using `pip`:

```powershell
# Create a virtual environment
$ python -m venv venv
# activate the virtual environment
$ venv\Scripts\Activate.ps1
# install the dependencies
$ pip install -r requirements.txt
```

Run the server using:

```powershell
$ uvicorn main:app --reload
```
or 

```powershell
$ python main.py
```

> Note: To compile the backend to a single executable, you can use `pyinstaller`. Refer to [pyinstaller documentation](https://pyinstaller.readthedocs.io/en/stable/usage.html) for more information.