
# aactclinica

Paquete de R para consultar y analizar ensayos clínicos registrados en ClinicalTrials.gov mediante una conexión remota a la base de datos AACT (Aggregate Analysis of ClinicalTrials.gov).

## Instalación

El paquete puede instalarse directamente desde GitHub:

```r
install.packages("remotes")
remotes::install_github("GohanGH/aactclinica")
```

Una vez instalado, se carga mediante:

```r
library(aactclinica)
```

## Configuración de credenciales

Para utilizar el paquete, es necesario disponer de una cuenta en AACT:

https://aact.ctti-clinicaltrials.org/

Las credenciales deben almacenarse de manera segura en el archivo `.Renviron`. Para editar este archivo desde R, ejecutar:

```r
usethis::edit_r_environ()
```

Añadir las siguientes líneas, sustituyendo los valores por las credenciales personales de AACT:

```text
AACT_USER="tu_usuario"
AACT_PASSWORD="tu_contraseña"
```

Guardar el archivo y reiniciar la sesión de R.

Las credenciales no deben incluirse directamente en el código ni publicarse en GitHub.

## Funciones disponibles

### resumen_ensayos_aact()

Consulta los estudios asociados a una determinada patología y devuelve:

- Fase clínica.
- Número de ensayos registrados con información de reclutamiento.
- Tamaño muestral promedio.

Ejemplo de uso:

```r
resumen_ensayos_aact("Melanoma")
```

### intervenciones_aact()

Analiza los estudios asociados a una determinada patología según el tipo de intervención y el estado del estudio.

Devuelve:

- Tipo de intervención.
- Estado del estudio.
- Número de ensayos.
- Tamaño muestral promedio.

Ejemplo de uso:

```r
intervenciones_aact("Diabetes")
```

La función utiliza consultas SQL que evitan contabilizar repetidamente un mismo ensayo dentro de cada combinación de tipo de intervención y estado.

## Tablas consultadas

El paquete consulta tres tablas del esquema `ctgov` de la base de datos PostgreSQL de AACT:

| Tabla | Contenido |
|---|---|
| ctgov.studies | Información general de los estudios, fases clínicas, estado y reclutamiento. |
| ctgov.conditions | Enfermedades y condiciones clínicas asociadas a cada estudio. |
| ctgov.interventions | Tipos de intervenciones investigadas. |

Las tablas se relacionan mediante el identificador único `nct_id`.

## Dependencias

- DBI
- RPostgres

Las consultas SQL se ejecutan directamente en el servidor remoto, sin necesidad de descargar la base de datos completa.

## Validación

El paquete ha sido documentado mediante roxygen2 y validado mediante `devtools::check()`, obteniendo cero errores y cero advertencias. La única nota corresponde a la imposibilidad de verificar la hora mediante un servicio externo.

## Licencia

MIT.

## Contexto académico

Paquete desarrollado como parte de la asignatura de Software de Gestión de Bases de Datos del Máster en Bioestadística de la Universidad Complutense de Madrid.
