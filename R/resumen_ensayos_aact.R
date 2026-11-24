#' Resumen de ensayos clinicos por fase
#'
#' Consulta la base de datos AACT y devuelve el numero
#' de ensayos y el reclutamiento medio por fase clinica.
#'
#' @param patologia Nombre de la enfermedad.
#' @return Un data.frame con el resumen de ensayos.
#' @export
#'
#' @examples
#' \dontrun{
#' resumen_ensayos_aact("Melanoma")
#' }

resumen_ensayos_aact <- function(patologia = "Melanoma") {

  usuario <- Sys.getenv("AACT_USER")
  clave <- Sys.getenv("AACT_PASSWORD")

  if (usuario == "" || clave == "") {
    stop("Configura tus credenciales en .Renviron.")
  }

  con <- DBI::dbConnect(
    RPostgres::Postgres(),
    dbname = "aact",
    host = "aact-db.ctti-clinicaltrials.org",
    port = 5432,
    user = usuario,
    password = clave,
    gssencmode = "disable",
    sslmode = "require"
  )

  on.exit(DBI::dbDisconnect(con), add = TRUE)

  consulta_sql <- "
    SELECT
      COALESCE(s.phase, 'No especificada') AS fase_clinica,
      COUNT(DISTINCT s.nct_id) AS num_ensayos,
      ROUND(AVG(s.enrollment), 1) AS reclutamiento_medio
    FROM ctgov.studies s
    WHERE EXISTS (
      SELECT 1
      FROM ctgov.conditions c
      WHERE c.nct_id = s.nct_id
        AND LOWER(c.name) LIKE LOWER($1)
    )
    AND s.enrollment IS NOT NULL
    GROUP BY s.phase
    ORDER BY num_ensayos DESC;
  "

  DBI::dbGetQuery(
    con,
    consulta_sql,
    params = list(paste0("%", patologia, "%"))
  )
}
