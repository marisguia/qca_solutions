#' qca_solutions Function
#'
#' Consolidates Conservative, Intermediate, and Parsimonious solutions from the `QCA package` (Dușa, 2019) into a unified data frame.
#'
#' @param c A conservative solution object of class "QCA_min".
#' @param i An intermediate solution object of class "QCA_min".
#' @param icp A character vector specifying which CnPn to include for intermediate solutions.
#' @param p A parsimonious solution object of class "QCA_min".
#' @param verbose Logical. If TRUE, displays progress messages.
#' @param save A character string specifying the file path to save the results.
#' @param round An integer indicating the number of decimal places to round numeric columns.
#' @param incl.cut A numeric value specifying the threshold for Consistency_PI.
#' @return A data frame consolidating the specified QCA solutions.
#' @examples
#' # Assuming you have QCA solution objects c_solution, i_solution, p_solution:
#' result <- qca_solutions(c = c_solution, i = i_solution, icp = c("C1P1"), p = p_solution, incl.cut = 0.8)
#' @export
qca_solutions <- function(c = NULL, i = NULL, icp = NULL, p = NULL, verbose = TRUE, save = NULL, round = NULL, incl.cut = NULL) {
  
  # Check for required packages
  if (!is.null(save)) {
    if (!requireNamespace("writexl", quietly = TRUE)) {
      stop("The 'writexl' package is required for saving results but is not installed. Please install it using install.packages('writexl').")
    }
  }
  
  # Validate input objects
  validate_input <- function(obj, obj_name) {
    if (!is.null(obj)) {
      if (!inherits(obj, "QCA_min")) {
        stop(paste("The", obj_name, "object must be of class 'QCA_min'."))
      }
    }
  }
  
  validate_input(c, "c")
  validate_input(i, "i")
  validate_input(p, "p")
  
  # Helper function to construct cases
  construct_cases <- function(incl_cov, obj_pims) {
    if ("cases" %in% colnames(incl_cov)) {
      cases_list <- incl_cov[["cases"]]
      if (is.list(cases_list)) {
        Cases <- sapply(cases_list, function(x) paste(x, collapse = ", "))
      } else {
        Cases <- as.character(cases_list)
      }
    } else {
      # Reconstruct cases from pims
      pims <- obj_pims
      # Ensure that pims columns match the prime implicants in incl_cov
      pims <- pims[, rownames(incl_cov), drop = FALSE]
      case_names <- rownames(pims)
      Cases <- sapply(rownames(incl_cov), function(pi) {
        x <- pims[[pi]]
        cases <- case_names[x >= 0.5]
        if (length(cases) == 0) {
          "-"
        } else {
          paste(cases, collapse = ", ")
        }
      })
    }
    return(Cases)
  }
  
  # Helper function to construct data frame
  construct_data_frame <- function(solution_name, incl_cov, sol_incl_cov, Cases, model_num = NA, cnpn = NA) {
    data <- data.frame(
      Solution = rep(solution_name, nrow(incl_cov)),
      Model = rep(model_num, nrow(incl_cov)),
      Intermediate_CnPn = rep(cnpn, nrow(incl_cov)),
      Prime_Implicants = rownames(incl_cov),
      Consistency_PI = incl_cov[["inclS"]],
      PRI_PI = incl_cov[["PRI"]],
      Raw_Coverage_PI = incl_cov[["covS"]],
      Unique_Coverage_PI = incl_cov[["covU"]],
      Solution_Consistency = rep(sol_incl_cov[["inclS"]], nrow(incl_cov)),
      Solution_PRI = rep(sol_incl_cov[["PRI"]], nrow(incl_cov)),
      Solution_Coverage = rep(sol_incl_cov[["covS"]], nrow(incl_cov)),
      Cases = Cases,
      stringsAsFactors = FALSE
    )
    
    # Filter based on incl.cut if provided
    if (!is.null(incl.cut)) {
      data <- data[data$Consistency_PI >= incl.cut, , drop = FALSE]
    }
    
    # Reset rownames
    rownames(data) <- NULL
    
    return(data)
  }
  
  # Helper to process conservative and parsimonious solutions
  process_con_par <- function(obj, solution_name, incl.cut) {
    if (verbose) {
      message(paste("Processing", solution_name, "solution..."))
    }
    
    all_data <- data.frame()
    
    if (!is.null(obj[["IC"]][["individual"]])) {
      # Multiple models
      for (model_num in seq_along(obj[["IC"]][["individual"]])) {
        incl_cov <- obj[["IC"]][["individual"]][[model_num]][["incl.cov"]]
        sol_incl_cov <- obj[["IC"]][["individual"]][[model_num]][["sol.incl.cov"]]
        Cases <- construct_cases(incl_cov, obj[["IC"]][["individual"]][[model_num]][["pims"]])
        data <- construct_data_frame(solution_name, incl_cov, sol_incl_cov, Cases, model_num = model_num)
        all_data <- rbind(all_data, data)
      }
    } else {
      # Single model
      incl_cov <- obj[["IC"]][["incl.cov"]]
      sol_incl_cov <- obj[["IC"]][["sol.incl.cov"]]
      Cases <- construct_cases(incl_cov, obj[["pims"]])
      data <- construct_data_frame(solution_name, incl_cov, sol_incl_cov, Cases)
      all_data <- rbind(all_data, data)
    }
    return(all_data)
  }
  
  # Helper to process intermediate solutions
  process_int <- function(obj, icp, incl.cut) {
    if (verbose) {
      message("Processing intermediate solution...")
    }
    
    if (is.null(icp)) {
      stop("You must specify which CnPn to include for intermediate solutions.")
    }
    
    all_data <- data.frame()
    for (cnpn in icp) {
      if (!cnpn %in% names(obj[["i.sol"]])) {
        stop(paste("CnPn", cnpn, "is not found in the intermediate solution object."))
      }
      
      current_sol <- obj[["i.sol"]][[cnpn]]
      
      if (!is.null(current_sol[["IC"]][["individual"]])) {
        # Multiple models
        for (model_num in seq_along(current_sol[["IC"]][["individual"]])) {
          incl_cov <- current_sol[["IC"]][["individual"]][[model_num]][["incl.cov"]]
          sol_incl_cov <- current_sol[["IC"]][["individual"]][[model_num]][["sol.incl.cov"]]
          Cases <- construct_cases(incl_cov, current_sol[["IC"]][["individual"]][[model_num]][["pims"]])
          data <- construct_data_frame("Intermediate", incl_cov, sol_incl_cov, Cases, model_num = model_num, cnpn = cnpn)
          all_data <- rbind(all_data, data)
        }
      } else {
        # Single model
        incl_cov <- current_sol[["IC"]][["incl.cov"]]
        sol_incl_cov <- current_sol[["IC"]][["sol.incl.cov"]]
        Cases <- construct_cases(incl_cov, current_sol[["pims"]])
        data <- construct_data_frame("Intermediate", incl_cov, sol_incl_cov, Cases, cnpn = cnpn)
        all_data <- rbind(all_data, data)
      }
    }
    
    return(all_data)
  }
  
  # Initialize final data frame
  final_df <- data.frame()
  
  # Process conservative solution
  if (!is.null(c)) {
    final_df <- rbind(final_df, process_con_par(c, "Conservative", incl.cut))
  }
  
  # Process parsimonious solution
  if (!is.null(p)) {
    final_df <- rbind(final_df, process_con_par(p, "Parsimonious", incl.cut))
  }
  
  # Process intermediate solution
  if (!is.null(i)) {
    final_df <- rbind(final_df, process_int(i, icp, incl.cut))
  }
  
  # Apply rounding to numeric columns if round is provided
  if (!is.null(round)) {
    numeric_columns <- sapply(final_df, is.numeric)
    final_df[numeric_columns] <- round(final_df[numeric_columns], round)
  }
  
  # Replace NAs with "-"
  final_df[is.na(final_df)] <- "-"
  
  # Reset rownames of final_df
  rownames(final_df) <- NULL
  
  # Save to file if specified
  if (!is.null(save)) {
    if (verbose) {
      message(paste("Saving results to", save))
    }
    # Use write_xlsx from writexl package
    writexl::write_xlsx(final_df, path = save)
  }
  
  # Done message
  if (verbose) {
    message("Done!")
  }
  
  # Return consolidated data frame
  return(final_df)
}
