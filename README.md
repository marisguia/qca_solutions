# qca_solutions

An R function for consolidating Conservative, Intermediate, and Parsimonious solutions from the "QCA package" (Dușa, 2019) into a unified data frame.

## Installation

Clone the repository and source the R script:

```r
source("qca_solutions.R")
```

## Usage

```r
# Load necessary packages
library(QCA)

# Your QCA solution objects
c_solution <- ... # Your conservative solution
i_solution <- ... # Your intermediate solution
p_solution <- ... # Your parsimonious solution

# Run the function
result <- qca_solutions(
  c = c_solution,
  i = i_solution,
  icp = c("C1P1", "C2P2"), # Specify your CnPn
  p = p_solution,
  incl.cut = 0.8,
  round = 2
)

# View the results
print(result)
```

## Dependencies

- **QCA** package: [CRAN link](https://cran.r-project.org/package=QCA)
- **writexl** package (for saving results to Excel)
  ```r
  install.packages("writexl")
  ```

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/marisguia/qca_solutions/blob/master/LICENSE) file for details.

## References

- Dușa, Adrian (2019). *QCA with R: A Comprehensive Resource*. Springer International Publishing.
