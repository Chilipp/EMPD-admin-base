FROM continuumio/miniconda3

ENV LATLONDATA /opt/latlon-utils-data
ENV LATLONRES 5m
ENV PYTEST /opt/test-env/bin/pytest

# Grab requirements.txt.
# ADD ./webapp/requirements.txt /tmp/requirements.txt

# Add our code
# ADD ./webapp /opt/webapp/
# WORKDIR /opt/webapp

RUN conda update -y conda

# Install dependencies
RUN conda create --yes -p /opt/test-env pytest pandas sqlalchemy psycopg2 shapely netcdf4 && \
    pip install latlon-utils && \
    conda clean --yes --all

# Install the dependencies to download WorldClim into a separate environment
RUN conda create -y -p ./wc xarray dask rasterio netCDF4 pip && \
    ./wc/bin/pip install latlon-utils && \
    ./wc/bin/python -m latlon_utils.download -v tavg prec -lat 0 90 -res 5m && \
    conda env remove -y -p ./wc && \
    conda clean --yes --all

CMD [ "/bin/bash" ]
