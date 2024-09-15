# qca_solutions

An R function for consolidating Conservative, Intermediate, and Parsimonious solutions from the "QCA package" (Dușa, 2019) into a unified data frame.

## Installation

### Option 1: Clone the repository

1. Clone the repository to your local machine using Git. Run this command in your terminal:
   
   ```bash
   git clone https://github.com/marisguia/qca_solutions.git
   ```
   
2. Then, in R, navigate to the folder where the script is located and source the script:

   ```r
   source("path/qca_solutions/qca_solutions.R")  # Replace "path" with your actual path
   ```

### Option 2: Download the script directly

1. Download the `qca_solutions.R` file.
2. In R, navigate to the folder where the script is saved, then source the script:

```r
source("download_path/qca_solutions/qca_solutions.R")  # Replace "download_path" with your actual path
```

## Usage
```r
qca_solutions(c = NULL, i = NULL, icp = NULL, p = NULL, verbose = TRUE, save = NULL, round = NULL, incl.cut = NULL)
```

Arguments

- c
  A conservative solution object of class "QCA_min" (typically obtained from the minimize() function in the QCA package).
  
- i
  An intermediate solution object of class "QCA_min" (typically obtained from the minimize() function in the QCA package).

- icp
  A character vector specifying which CnPn to include for intermediate solutions.

- p
  A parsimonious solution object of class "QCA_min" (typically obtained from the minimize() function in the QCA package).

- verbose
  A logical value. If TRUE (default), progress messages are displayed during execution.

- save
  A character string specifying the file path to save the results. If NULL (default), the results are not saved.

- round
  An integer specifying the number of decimal places to round numeric columns (e.g., 2 for two decimal places). If NULL (default), no rounding is applied.

- incl.cut
  A numeric value specifying the threshold for Consistency_PI. Prime implicants with Consistency_PI below this value are excluded. If NULL (default), no filtering based on consistency is applied.

```r
# Load necessary packages
library(QCA)

# Truth Table. Lipset dataset (1959).
tt <- truthTable(LF, outcome = SURV, incl.cut = .5) # Low incl.cut to generate multiple models

# Solutions
c_solution <- minimize(tt) # Conservative
i_solution <- minimize(tt, include = "?", dir.exp = "1, 1, 1, 1, 1") # Intermediate
p_solution <- minimize(tt, include = "?") # Parsimonious

# Single solution
qca_c_solution <- qca_solutions(c = c_solution, round = 2)

print(qca_c_solution)

# Full usage
qca_results <- qca_solutions(
  c = c_solution,            # Conservative solution object
  i = i_solution,            # Intermediate solution object
  icp = c("C1P3", "C2P1"),   # CnPn to include for intermediate solutions
  p = p_solution,            # Parsimonious solution object
  verbose = TRUE,            # Display progress messages
  round = 3,                 # Round numeric values to 3 decimal places
  incl.cut = 0.8,            # Set a consistency threshold for prime implicants
  save = "qca_results.xlsx"  # Save results to an Excel file
)

# View the consolidated results
print(qca_results)
```

## Dependencies

- **QCA** package: [CRAN link](https://cran.r-project.org/package=QCA)
- **writexl** package: [CRAN link](https://CRAN.R-project.org/package=writexl)

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/marisguia/qca_solutions/blob/master/LICENSE) file for details.

## References

- Dușa, Adrian (2019). *QCA with R: A Comprehensive Resource*. Springer International Publishing.
- Lipset MS (1959) Some social requisites of democracy: economic development and political legitimacy. Am Polit Sci Rev 53(1):69–105.
