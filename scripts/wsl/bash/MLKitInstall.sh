apt update && apt upgrade -y
# Cuda 12.8
if nvcc --version > /dev/null 2>&1; then
    echo "Cuda already installed"
else
    wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda_12.8.0_570.86.10_linux.run
    sh cuda_12.8.0_570.86.10_linux.run
    source ~/.bashrc
    if nvcc --version > /dev/null 2>&1; then
        echo "Cuda installed successfully"
    else 
        echo "export PATH=/usr/local/cuda-12.8/bin${PATH:+:${PATH}}" >> ~/.bashrc
        echo "export LD_LIBRARY_PATH=/usr/local/cuda-12.8/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}" >> ~/.bashrc
        source ~/.bashrc
        echo "Cuda path set successfully"   
    fi
fi

# Conda
if conda --version > /dev/null 2>&1; then
    echo "Conda already installed"
else
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    bash Miniconda3-latest-Linux-x86_64.sh -b
    rm Miniconda3-latest-Linux-x86_64.sh
    source ~/.bashrc
    if conda --version > /dev/null 2>&1; then
        echo "Conda installed successfully"
fi