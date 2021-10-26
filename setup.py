import setuptools

with open("README.md", "r", encoding="utf-8") as fh:
    long_description = fh.read()

setuptools.setup(
    name="BMI500HW7",
    version="0.0.1",
    author="Chenbin Huang",
    author_email="chenbin.huang@@emory.edu",
    description="BMI 500 HW7 AKI Identification and Cluster",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ChenbinHuang/BMI500_HW7_AKI",
    project_urls={
        "Bug Tracker": "https://github.com/ChenbinHuang/BMI500_HW7_AKI/issues",
    },
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    python_requires=">=3.7",
    install_requires=[
          'scikit-learn',
          'matplotlib',
          'pandas',
          'umap-learn'
      ],
    include_package_data=True
)