#!/usr/bin/bash

set -u
set -e

usage="$(basename "$0") root -- Build software and install in root."

if [[ $# -lt 1 || $# -gt 1  || $1 == "-h" ]]
then
    echo "$usage"
    exit 0
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOT=$1
module reset
module load gcc/7.4.0
module load python/3.7.0
python3 -m venv $ROOT --system-site-packages

cat >$ROOT/environment.sh << EOL
module reset
module load gcc/7.4.0
module load cuda
module load cmake
module load git
module load netlib-lapack/3.8.0
module load hdf5/1.10.3

export LD_LIBRARY_PATH=$ROOT/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/bin:\$PATH
export CPATH=$ROOT/include:\$CPATH
export LIBRARY_PATH=$ROOT/lib:\$LIBRARY_PATH
export CC=\${OLCF_GCC_ROOT}/bin/gcc
export CXX=\${OLCF_GCC_ROOT}/bin/g++
export LDSHARED="\${OLCF_GCC_ROOT}/bin/gcc -shared"
export VIRTUAL_ENV=$ROOT
EOL

cp -a $DIR/../../check-requirements.py $ROOT/bin

source $ROOT/environment.sh

mkdir -p /tmp/$USER-glotzerlab-software
cd /tmp/$USER-glotzerlab-software

python3 -m pip install --upgrade pip
python3 -m pip install --progress-bar off --no-binary :all: --no-use-pep517 --no-build-isolation cython
python3 -m pip install --progress-bar off --no-binary :all: --no-use-pep517 --no-build-isolation \
    mpi4py \
    six \
    numpy \
    tables \
    numexpr \
    deprecation \
    breathe \
    cloudpickle \
    filelock \
    jinja2 \
    tqdm \
    packaging

# TBB
curl -sSLO https://github.com/oneapi-src/oneTBB/archive/v2020.2.tar.gz \
    && echo "4804320e1e6cbe3a5421997b52199e3c1a3829b2ecb6489641da4b8e32faf500  v2020.2.tar.gz" | sha256sum -c - \
    && tar -xzf v2020.2.tar.gz -C . \
    && cd oneTBB-2020.2 \
    && make \
    && install -d $ROOT/lib \
    && install -m755 build/linux_*release/*.so* ${ROOT}/lib \
    && install -d $ROOT/include \
    && cp -a include/tbb $ROOT/include \
    && cd .. \
    && rm -rf oneTBB-2020.2 \
    && rm v2020.2.tar.gz \
    || exit 1

# embree is not available for power9

# scipy
curl -sSLO https://github.com/scipy/scipy/releases/download/v1.5.2/scipy-1.5.2.tar.gz \
    && echo "066c513d90eb3fd7567a9e150828d39111ebd88d3e924cdfc9f8ce19ab6f90c9  scipy-1.5.2.tar.gz" | sha256sum -c - \
    && tar -xzf scipy-1.5.2.tar.gz -C . \
    && cd scipy-1.5.2 \
    && LAPACK=${OLCF_NETLIB_LAPACK_ROOT}/lib64/liblapack.so BLAS=${OLCF_NETLIB_LAPACK_ROOT}/lib64/libblas.so python3 setup.py install \
    && rm -rf scipy-1.5.2 \
    || exit 1



 git clone --recursive --branch v1.2.2 --depth 1 https://github.com/glotzerlab/rowan \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./rowan/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./rowan \
    && rm -rf rowan \
    || exit 1

 git clone --recursive --branch v0.2.0 --depth 1 https://github.com/glotzerlab/coxeter \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./coxeter/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./coxeter \
    && rm -rf coxeter \
    || exit 1

# git clone --recursive --branch v0.7.1 --depth 1 https://github.com/glotzerlab/garnett \
#    && rm -f garnett/*.toml \
#    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
#    && check-requirements.py ./garnett/requirements.txt \
#    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./garnett \
#    && rm -rf garnett \
#    || exit 1

 git clone --recursive --branch v2.2.0 --depth 1 https://github.com/glotzerlab/gsd \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./gsd \
    && rm -rf gsd \
    || exit 1

 git clone --recursive --branch v1.0.1 --depth 1 https://github.com/glotzerlab/libgetar \
    && rm -f libgetar/*.toml \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./libgetar/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./libgetar \
    && rm -rf libgetar \
    || exit 1

 git clone --recursive --branch v1.7.0 --depth 1 https://github.com/glotzerlab/plato \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./plato \
    && rm -rf plato \
    || exit 1

 git clone --recursive --branch v1.3.0 --depth 1 https://github.com/glotzerlab/signac \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./signac/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./signac \
    && rm -rf signac \
    || exit 1

 git clone --recursive --branch v0.9.0 --depth 1 https://github.com/glotzerlab/signac-flow \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./signac-flow/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./signac-flow \
    && rm -rf signac-flow \
    || exit 1



 git clone --recursive --branch v2.2.0 --depth 1 https://github.com/glotzerlab/freud \
    && rm -f freud/*.toml \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./freud/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./freud \
    && rm -rf freud \
    || exit 1

 git clone --recursive --branch v0.2.0 --depth 1 https://github.com/glotzerlab/fsph \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./fsph \
    && rm -rf fsph \
    || exit 1

 git clone --recursive --branch v0.2.5 --depth 1 https://github.com/glotzerlab/pythia \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && check-requirements.py ./pythia/requirements.txt \
    && python3 -m pip install --no-cache-dir --no-use-pep517 --no-build-isolation --no-deps --ignore-installed ./pythia \
    && rm -rf pythia \
    || exit 1

 git clone --recursive --branch v2.9.3 --depth 1 https://github.com/glotzerlab/hoomd-blue hoomd \
    && cd hoomd \
    && mkdir -p build \
    && cd build \
    && export CFLAGS="-mcpu=power9 -mtune=power9" CXXFLAGS="-mcpu=power9 -mtune=power9" \
    && cmake ../ -DPYTHON_EXECUTABLE="`which python3`" -DENABLE_CUDA=on -DENABLE_MPI=on -DENABLE_TBB=off -DBUILD_JIT=off -DBUILD_TESTING=off -DENABLE_MPI_CUDA=on -DCMAKE_INSTALL_PREFIX=`python3 -c "import site; print(site.getsitepackages()[0])"` \
    && make install -j4 \
    && cd ../../ \
    && rm -rf hoomd \
    || exit 1