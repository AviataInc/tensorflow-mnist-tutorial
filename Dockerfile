# Source image
FROM python:3.6.2-stretch

# Install dependencies
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg

# Python packages for ML
RUN pip install numpy
RUN pip install pandas
RUN pip install scipy
RUN pip install wheel
RUN pip install sklearn
RUN pip install quandl
RUN pip install matplotlib
RUN pip install tensorflow

# Default command
CMD python

