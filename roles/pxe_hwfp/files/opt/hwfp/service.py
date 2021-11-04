#!/usr/bin/python
# -*- coding: utf-8 -*-
# vim:set fileformat=unix shiftwidth=4 softtabstop=4 expandtab:
# kate: end-of-line unix; space-indent on; indent-width 4; remove-trailing-spaces modified;
#
# Copyright: (c) 2021, Jakob Meng <jakobmeng@web.de>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
#
# Receives uploaded files and store them in new subdirectory of database directory.
#
# Usage:
#
#  # Create db directory
#  mkdir /var/lib/hwfp
#
#  # Run service with asgi server
#  uvicorn service:app
#
#  # Upload files to service
#  date > file1
#  date > file2
#  curl -v -F "files=@./file1" -F "files=@./file2" http://127.0.0.1:8000/
#
#  # Find uploaded files on server
#  find /var/lib/hwfp -type f
#
# Ref.: https://fastapi.tiangolo.com/tutorial/request-files/

import datetime
import fastapi
import os
import re
import typing

app = fastapi.FastAPI()
db_path = "/var/lib/hwfp"


@app.get("/")
async def main():
    return fastapi.responses.HTMLResponse(content="""
<body>
<form action="/" enctype="multipart/form-data" method="post">
<input name="files" type="file" multiple>
<input type="submit">
</form>
</body>
    """)


@app.post("/")
async def post_files(files: typing.List[fastapi.UploadFile] = fastapi.File(...)):
    timestamp = datetime.datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    dir = os.path.join(db_path, timestamp)

    if not os.path.exists(dir):
        os.mkdir(dir)

    for file in files:
        if not file.filename:
            raise fastapi.HTTPException(status_code=400, detail="no filename specified")

        # remove forbidden characters to prevent security issues, e.g. replace
        # path separators to prevent overwriting files in parent directories
        filename = re.sub(r'[^a-zA-Z0-9._-]', "_", file.filename)

        with open(os.path.join(dir, filename), "wb") as f:
            f.write(file.file.read())

    return fastapi.Response(status_code=fastapi.status.HTTP_200_OK)
