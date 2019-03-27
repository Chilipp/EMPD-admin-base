FROM postgres:11.2

ENV LATLONDATA /opt/latlon-utils-data
ENV LATLONRES 5m
ENV PYTEST /opt/test-env/bin/pytest
ENV PATH /opt/conda/bin:$PATH
ENV DATABASE_URL postgresql://postgres@localhost

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    conda update -y conda && \
    conda clean -tipsy && \
    conda init bash

# Install dependencies
RUN conda create --yes -p /opt/test-env pytest pandas sqlalchemy psycopg2 shapely netcdf4 pip requests gitpython && \
    /opt/test-env/bin/pip install latlon-utils && \
    conda clean --yes --all

# Install the dependencies to download WorldClim into a separate environment
RUN conda create -y -p ./wc xarray dask rasterio netCDF4 pip && \
    ./wc/bin/pip install latlon-utils && \
    ./wc/bin/python -m latlon_utils.download -v tavg prec -lat 0 90 -res 5m && \
    conda env remove -y -p ./wc && \
    conda clean --yes --all

RUN conda install -y psycopg2 sqlalchemy pandas pytest ipython openpyxl xlrd

RUN cat /root/.bashrc >> /etc/bash.bashrc

COPY ./start_pg_server.sh /usr/local/bin/start_pg_server

# download tini
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

ENTRYPOINT ["tini", "--"]
