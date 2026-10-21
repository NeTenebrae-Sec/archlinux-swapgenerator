# archlinux-swapgenerator

<div align="center">

![Arch Linux](https://img.shields.io/badge/Arch_Linux-11111b?style=flat&logo=arch-linux&logoColor=f38ba8)
![Bash](https://img.shields.io/badge/Bash-1e1e2e?style=flat&logo=gnu-bash&logoColor=4eaa25)
![ZRAM](https://img.shields.io/badge/ZRAM-zstd-313244?style=flat&logo=linux&logoColor=cdd6f4)
![Idempotente](https://img.shields.io/badge/Ejecuci%C3%B3n-Idempotente-11111b?style=flat&logo=readthedocs&logoColor=f38ba8)

</div>

**Configuración de memoria y swap para Arch en equipos modestos.** `archlinux-swapgenerator` es un script de Bash que ajusta el rendimiento de memoria de un Arch Linux con poca RAM: configura **ZRAM** con el algoritmo de compresión que elijas, afina `vm.swappiness` y opcionalmente instala **earlyoom** para recuperarse de la presión de memoria. Es **idempotente**: solo toca lo que cambia, y con `--dry-run` ves todo sin aplicar nada.

## Características

- **ZRAM configurable** — tamaño automático (con tope) o manual, algoritmo de compresión a elección (`zstd` por defecto).
- **Swappiness afinado** — escribe `/etc/sysctl.d/99-swappiness.conf` (150 por defecto).
- **earlyoom opcional** — instala y habilita `earlyoom` para cortar procesos antes de que el sistema se congele; se omite con `--skip-earlyoom`.
- **Idempotente** — regenera configs solo si difieren de lo deseado; seguro de re-ejecutar.
- **`--dry-run`** — muestra los cambios sin tocar el sistema.

## Uso

```bash
git clone https://github.com/NeTenebrae-Sec/archlinux-swapgenerator.git
cd archlinux-swapgenerator
sudo ./swap-generator.sh            # configuración automática
sudo ./swap-generator.sh --dry-run  # previsualizar sin aplicar
```

### Opciones

| Opción | Descripción | Default |
|---|---|---|
| `--zram-size <MB\|G>` | Tamaño manual de ZRAM (ej: `12288` o `12G`) | automático |
| `--max-zram-mb <MB>` | Tope para el tamaño automático | `16384` |
| `--swappiness <N>` | Valor de `vm.swappiness` | `150` |
| `--algo <name>` | Algoritmo de compresión | `zstd` |
| `--skip-earlyoom` | No instalar/habilitar earlyoom | — |
| `--dry-run` | Ver cambios sin aplicar | — |

## Estructura

| Ruta | Rol |
|---|---|
| `swap-generator.sh` | Punto de entrada y orquestación |
| `modules/zram.sh` | Configuración de `/etc/systemd/zram-generator.conf` |
| `modules/swappiness.sh` | Ajuste de `vm.swappiness` |
| `modules/earlyoom.sh` | Instalación y habilitación de earlyoom |
| `helpers/` | Argumentos, config, logging, tamaño y detección de sistema |

## Licencia

GNU General Public License v3.0.
