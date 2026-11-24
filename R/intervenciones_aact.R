#' Analisis de ensayos clinicos por tipo de intervencion
#'
#' Consulta la base de datos AACT y devuelve el numero de
#' ensayos clinicos, el reclutamiento medio y el estado
#' de los estudios segun el tipo de intervencion.
#'
#' @param patologia Nombre de la enfermedad de interes.
#'
#' @return Un data.frame con los resultados agrupados por
#' tipo de intervencion y estado del estudio.
#' @export
#'
#' @examples
#' \dontrun{
#' intervenciones_aact("Diabetes")
#' }

intervenciones_aact <- function(patologia = "Diabetes") {

  usuario <- Sys.getenv("AACT_USER")
  clave <- Sys.getenv("AACT_PASSWORD")

  if (usuario == "" || clave == "") {
    stop("Configura AACT_USER y AACT_PASSWORD en .Renviron.")
  }

  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = "aact",
    host = "aact-db.ctti-clinicaltrials.org",
    port = 5432,
    user = usuario,
    password = clave
  )

  on.exit(DBI::dbDisconnect(con), add = TRUE)

  consulta_sql <- "
    WITH ensayos AS (
      SELECT DISTINCT
        s.nct_id,
        i.intervention_type,
        s.overall_status,
        s.enrollment
      FROM ctgov.studies s
      INNER JOIN ctgov.conditions c
        ON s.nct_id = c.nct_id
      INNER JOIN ctgov.interventions i
        ON s.nct_id = i.nct_id
      WHERE LOWER(c.name) LIKE LOWER($1)
    )
    SELECT
      intervention_type AS tipo_intervencion,
      overall_status AS estado,
      COUNT(*) AS num_ensayos,
      ROUND(AVG(enrollment), 1) AS reclutamiento_medio
    FROM ensayos
    GROUP BY intervention_type, overall_status
    ORDER BY num_ensayos DESC;
  "

  DBI::dbGetQuery(
    con,
    consulta_sql,
    params = list(paste0("%", patologia, "%"))
  )
}

