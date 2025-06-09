# foodclim

<!-- quarto render -->

<!-- badges: start -->
[![Project Status: Active - The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![](https://img.shields.io/badge/CoMSES%20Network-not%20published-F5514D.svg)](https://www.comses.net/)
[![](https://img.shields.io/badge/OSF%20DOI-10.17605/OSF.IO/ZGVMP-1284C5.svg)](https://doi.org/10.17605/OSF.IO/ZGVMP)
[![fair-software.eu](https://img.shields.io/badge/fair--software.eu-%E2%97%8F%20%20%E2%97%8F%20%20%E2%97%8B%20%20%E2%97%8F%20%20%E2%97%8B-orange)](https://fair-software.eu)
[![License:
MIT](https://img.shields.io/badge/license-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
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

Vartanian, D., Garcia, L., & Carvalho, A. M. (2025). *FoodClim:
Simulating food yield responses to climate change in NetLogo* \[Computer
software, NetLogo model\]. <https://doi.org/10.17605/OSF.IO/ZGVMP>

A BibTeX entry for LaTeX users is:

``` latex
@Misc{vartanian2025,
  title = {FoodClim: Simulating food yield responses to climate change in NetLogo},
  author = {{Daniel Vartanian} and {Leandro Garcia} and {Aline Martins de Carvalho}},
  year = {2025},
  doi = {https://doi.org/10.17605/OSF.IO/ZGVMP},
  note = {NetLogo model}
}
```

## How to Contribute

[![](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

Contributions are welcome! Whether it's reporting bugs, suggesting
features, or improving documentation, your input is valuable.

[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/danielvartan)

You can also support the development of `FoodClim` by becoming a
sponsor. Click [here](https://github.com/sponsors/danielvartan) to make
a donation. Please mention `FoodClim` in your donation message.

## License

[![](https://img.shields.io/badge/license-MIT-green.svg)](https://choosealicense.com/licenses/mit/)

`FoodClim` code is licensed under the [MIT
License](https://opensource.org/license/mit). This means you can use,
modify, and distribute the code freely, as long as you include the
original license and copyright notice in any copies or substantial
portions of the software.

## Acknowledgments

We gratefully acknowledge the contributions of [Stephen E.
Fick](https://orcid.org/0000-0002-3548-6966), [Robert J.
Hijmans](https://orcid.org/0000-0001-5872-2872), and the entire
[WorldClim](https://worldclim.org/) team for their dedication to
creating and maintaining the WorldClim datasets. Their work has been
instrumental in enabling researchers and practitioners to access
high-quality climate data.

We also acknowledge the World Climate Research Programme
([WCRP](https://www.wcrp-climate.org/)), which, through its Working
Group on Coupled Modelling, coordinated and promoted the Coupled Model
Intercomparison Project Phase 6
([CMIP6](https://pcmdi.llnl.gov/CMIP6/)).

We thank the climate modeling groups for producing and sharing their
model outputs, the Earth System Grid Federation
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
        This work was developed with support from the Research and 
        Extension Center 
        <a href="https://www.fsp.usp.br/sustentarea/">Sustentarea</a>
         at the University of São Paulo (<a href="https://www5.usp.br/">USP</a>).
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
        Technological Development (<a href="https://www.gov.br/cnpq/">CNPq</a>) (grant no. 444588/2023-0)
      </p>
    </td>
  </tr>
</table>
