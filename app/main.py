from typing import Annotated
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import HTMLResponse
from sqlalchemy import create_engine, Column, Integer, Float, String, Date, MetaData, Table
from sqlalchemy.orm import sessionmaker, declarative_base

import pandas as pd

app = FastAPI()

Base = declarative_base()

class Sale(Base):
    __tablename__ = "sales"
    id = Column(Integer, primary_key=True, autoincrement=True)
    date = Column(Date)
    gross_sales = Column(Float)

DATABASE_URL = "sqlite:///data.db"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
Base.metadata.create_all(engine)
SessionLocal = sessionmaker(bind=engine)

@app.post("/files/")
async def create_file(file: Annotated[bytes | None, File()] = None):
    if not file:
        return {"message": "No file sent"}
    else:
        return {"file_size": len(file)}

@app.post("/uploadfile/")
async def create_upload_file(file: UploadFile | None = None):
    if not file:
        return {"message": "No upload file sent"}
    else:
        df = pd.read_csv(file.file)
        if not {"Day", "Gross sales"}.issubset(df.columns):
            return {"error": "CSV musi zawierać kolumny: data, dochod_brutto"}


        df["Day"] = pd.to_datetime(df["Day"]).dt.date

        db = SessionLocal()
        for _, row in df.iterrows():
            sale = Sale(date=row["Day"], gross_sales=row["Gross sales"])
            db.add(sale)

        db.commit()
        db.close()

        return HTMLResponse(content=f"<h3>Podgląd pliku: {file.filename}</h3>")


@app.get("/")
async def main():
    content = """
<body>
<form action="/uploadfile/" enctype="multipart/form-data" method="post">
<input name="file" type="file">
<input type="submit">
</form>
</body>
    """
    return HTMLResponse(content=content)