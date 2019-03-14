FROM continuumio/miniconda3

ENV LATLONDATA /opt/latlon-utils-data
ENV LATLONRES 5m

# Grab requirements.txt.
# ADD ./webapp/requirements.txt /tmp/requirements.txt

# Add our code
# ADD ./webapp /opt/webapp/
# WORKDIR /opt/webapp

RUN conda update -y conda

# Install dependencies
RUN conda install --yes pandas sqlalchemy psycopg2 shapely netcdf4
RUN pip install latlon-utils

# Install the dependencies to download WorldClim into a separate environment
RUN conda create -y -p ./wc xarray dask rasterio netCDF4 pip

# Download and process WorldClim
RUN ./wc/bin/pip install latlon-utils
RUN ./wc/bin/python -m latlon_utils.download -v tavg prec -lat 0 90 -res 5m

# Remove the conda environment
RUN conda env remove -y -p ./wc

# Remove unnecessary packages
RUN conda clean --yes --all

CMD [ "/bin/bash" ]
