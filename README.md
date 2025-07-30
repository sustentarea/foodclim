# FoodClim

<!-- Quarto render -->

<!-- badges: start -->
[![Project Status: WIP - Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![](https://img.shields.io/badge/CoMSES%20Network-not%20published-F5514D.svg)](https://www.comses.net/)
[![](https://img.shields.io/badge/OSF%20DOI-10.17605/OSF.IO/ZGVMP-1284C5.svg)](https://doi.org/10.17605/OSF.IO/ZGVMP)
[![License:
GPLv3](https://img.shields.io/badge/license-GPLv3-bd0000.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)
<!-- badges: end -->

## Overview

`FoodClim` is a [NetLogo](https://ccl.northwestern.edu/netlogo/) model
for simulating and visualizing how food yield responds to different
climate conditions. It is designed to support empirically grounded
agent-based models on food systems and to improve the reproducibility of
simulations by enabling [parallel
execution](#integrating-with-other-models) alongside other models.

The model runs in parallel with the
[`LogoClim`](https://github.com/sustentarea/logoclim) model, which
provides climate data from [WorldClim 2.1](https://worldclim.org/).

> If you find this project useful, please consider giving it a star!  
> [![GitHub repo
> stars](https://img.shields.io/github/stars/sustentarea/foodclim)](https://github.com/sustentarea/foodclim/)

![FoodClim Interface](images/foodclim-interface-bra-10m.png)

## How to Use It

Refer to the [`LogoClim`](https://github.com/sustentarea/logoclim)
installation guide for detailed steps on installing the required
dependencies.

Once `LogoClim` is installed, you can run the `FoodClim` model by
specifying the path to your `LogoClim` installation in the `FoodClim`
interface. This allows `FoodClim` to access climate data provided by
`LogoClim` during simulations.

Refer to the `Info` tab in the model for additional details.

### Integrating with Other Models

`FoodClim` can be integrated with other models using the
[LevelSpace](https://ccl.northwestern.edu/netlogo/docs/ls.html) (`ls`)
extension for NetLogo. LevelSpace enables parallel execution and
communication between multiple models. This approach supports more
comprehensive simulations and facilitates the study of complex
interactions between food systems and environmental processes.

## How to Cite

If you use this model in your research, please cite it to acknowledge
the effort invested in its development and maintenance. Your citation
helps support the ongoing improvement of the model.

To cite `FoodClim` in publications please use the following format:

Vartanian, D., Garcia, L., & Carvalho, A. M. (2025). *FoodClim: Food
yield responses to climate change in NetLogo* \[Computer software\].
<https://doi.org/10.17605/OSF.IO/ZGVMP>

A BibTeX entry for LaTeX users is:

``` latex
@Misc{vartanian2025,
  title = {FoodClim: Food yield responses to climate change in NetLogo},
  author = {{Daniel Vartanian} and {Leandro Garcia} and {Aline Martins de Carvalho}},
  year = {2025},
  doi = {https://doi.org/10.17605/OSF.IO/ZGVMP},
  note = {NetLogo model}
}
```

## How to Contribute

[![](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

Contributions are welcome! Whether you want to report bugs, suggest
features, or improve the code or documentation, your input is highly
valued.

When contributing code, please follow the [tidy design
principles](https://design.tidyverse.org/) and the [tidyverse style
guide](https://style.tidyverse.org/) whenever possible.

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/danielvartan)

You can also support the development of `FoodClim` by becoming a
sponsor. Click [here](https://github.com/sponsors/danielvartan) to make
a donation. Please mention `FoodClim` in your donation message.

## License

[![](https://img.shields.io/badge/license-GPLv3-bd0000.svg)](https://www.gnu.org/licenses/gpl-3.0)

``` text
Copyright (C) 2025 Daniel Vartanian

FoodClim is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <https://www.gnu.org/licenses/>.
```

## Acknowledgments

We gratefully acknowledge [Stephen E.
Fick](https://orcid.org/0000-0002-3548-6966), [Robert J.
Hijmans](https://orcid.org/0000-0001-5872-2872), and the entire
[WorldClim](https://worldclim.org/) team for their outstanding work in
creating and maintaining the WorldClim datasets, which form the
foundation of this project.

We thank the [Climatic Research
Unit](https://www.uea.ac.uk/groups-and-centres/climatic-research-unit)
at the [University of East Anglia](https://www.uea.ac.uk/) and the
United Kingdom's [Met Office](https://www.metoffice.gov.uk/) for
developing and providing access to the
[CRU-TS-4.09](https://crudata.uea.ac.uk/cru/data/hrg/cru_ts_4.09/)
dataset, a vital source of historical climate data.

We also acknowledge the World Climate Research Programme
([WCRP](https://www.wcrp-climate.org/)), its Working Group on Coupled
Modelling, and the Coupled Model Intercomparison Project Phase 6
([CMIP6](https://pcmdi.llnl.gov/CMIP6/)) for coordinating and advancing
global climate model development.

We are grateful to the climate modeling groups for producing and sharing
their model outputs, the Earth System Grid Federation
([ESGF](https://esgf.llnl.gov/)) for archiving and providing access to
the data, and the many funding agencies that support CMIP6 and ESGF.

<table>
  <tr>
    <td width="30%">
      <br/>
      <br/>
      <p align="center">
        <a href="https://www.fsp.usp.br/sustentarea/">
          <img src="images/sustentarea-logo.svg" width="125"/>
        </a>
      </p>
      <br/>
    </td>
    <td width="70%">
      <p>
        This work was developed with support from the 
        <a href="https://www.fsp.usp.br/sustentarea/">Sustentarea</a>
         Research and Extension Center at the University of São Paulo (<a href="https://www5.usp.br/">USP</a>).
      </p>
    </td>
  </tr>
</table>

<table>
  <tr>
    <td width="30%">
      <br/>
      <p align="center">
        <a href="https://www.gov.br/cnpq/">
          <img src="images/cnpq-logo.svg" width="150"/>
        </a>
      </p>
      <br/>
    </td>
    <td width="70%">
      <p>
        This work was supported by the Department of Science and 
        Technology of the Secretariat of Science, Technology, and Innovation 
        and of the Health Economic-Industrial Complex (<a href="https://www.gov.br/saude/pt-br/composicao/sectics/">SECTICS</a>)  of the <a href="https://www.gov.br/saude/pt-br/composicao/sectics/">Ministry of Health</a> 
        of Brazil, and the National Council for Scientific and 
        Technological Development (<a href="https://www.gov.br/cnpq/">CNPq</a>) (grant no. 444588/2023-0).
      </p>
    </td>
  </tr>
</table>
