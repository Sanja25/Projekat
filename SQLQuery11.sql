--Prikazacemo sve iz tabele da vidimo da li se sve prikazuje kao u Excel-u
Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccination
order by 3,4

--Pri prikazivanju tabele, primijeceno je da se svaki red duplira i ima null vrijednosti za populaciju
--U svakom upitu smo izbacili populaciju koja je 0
Select *
From PortfolioProject..CovidDeaths
Where population  is not null and continent is not null
order by 3,4

--Prikazacemo za svaku državu broj novih sluèajeva, ukupnih sluèajeva i broj smrnih sluèajeva, sortiranih po datumu
Select Location, date, total_cases, new_cases, total_deaths
From PortfolioProject..CovidDeaths
where population is not null and continent is not null
order by 1,2


--Pronalazimo procente
 
 --Koji je procenat umrlih u odnosu na broj zarazenih?

 Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as procenatUmrlih
From PortfolioProject..CovidDeaths
where population is not null and continent is not null
order by 1,2

 -- Prikazivanje procenata za Srbiju 
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as procenatUmrlih
From PortfolioProject..CovidDeaths
where population is not null and  location like '%Serbia%' and continent is not null
order by 1,2

--Koji je procenat zarazenih u  odnosu na broj stanovnika?

Select Location, date, total_cases, population, (total_cases / population) * 100  as procenatZarazenih 
From PortfolioProject..CovidDeaths
where population is not null and  location like '%Serbia%'
order by 1,2


--Koja drzava je imala najveci procenat zaraženih? 
--Nije isto kad kažemo koja država ima najveæi broj zaraženih i koja ima najveæi procenat  zaražene populacije.

Select Location, population, MAX(total_cases) as najviseZarazenih, MAX((total_cases / population)) * 100 as procenatZarazenePopulacije
From PortfolioProject..CovidDeaths
where population is not null
Group by Location,population
order by procenatZarazenePopulacije desc

--Prikazivanje u Tableu

Select Location, population,date, MAX(total_cases) as najviseZarazenih, MAX((total_cases / population)) * 100 as procenatZarazenePopulacije
From PortfolioProject..CovidDeaths
where population is not null
Group by Location,population,date
order by procenatZarazenePopulacije desc


--ptikazujemo ukupno umrlih  za svaku drzavu
Select Location, SUM(cast(new_deaths  as int)) as najviseUmrlih1
From PortfolioProject..CovidDeaths
where population is not null and continent is  null and location not in ('World', 'European Union', 'International')
Group by Location
order by najviseUmrlih1 desc


--Prikazujemo drzavu koja je imala najveci broj smrtnih slucajeva i prvo pojavljivanje kastovanja.
Select Location, MAX(cast(total_deaths  as int)) as najviseUmrlih
From PortfolioProject..CovidDeaths
where population is not null and continent is not null
Group by Location
order by najviseUmrlih desc

-- Pojavljuje se problem da u lokaciji imamo kontinente.

--Istrazujemo zarazenost na nivou kontinenta u odnosu na populaciju

Select continent, MAX(cast(total_deaths  as int)) as najviseUmrlih
From PortfolioProject..CovidDeaths
where population is not null and continent is  not null
Group by continent
order by najviseUmrlih desc

--najpravilnije
Select Location, MAX(cast(total_deaths  as int)) as najviseUmrlih
From PortfolioProject..CovidDeaths
where population is not null and continent is null
Group by Location
order by najviseUmrlih desc

--Za svaki datum pronacicemo ukupan broj zarazenih, umrlih i procenat u cijelom svijetu 
Select date, SUM(new_cases) as ukupnoSlucajeva, SUM(cast(new_deaths as int)) as ukupnoUmrlih, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as procenatUmrlih
From PortfolioProject..CovidDeaths
where continent is not null and population is not null
Group by date
order by 1,2

--Pronalazimo broj ukupno zarazenih i umrlih na cijelom svijetu od pocetka pandemije

Select  SUM(new_cases) as ukupnoSlucajeva, SUM(cast(new_deaths as int)) as ukupnoUmrlih, SUM(cast(new_deaths as int ))/SUM(new_cases)*100 as procenatUmrlih
From PortfolioProject..CovidDeaths
where continent is not null and population is not null
order by 1,2



 
--spojicemo nase dvije tabele (po lokaciji i datumu)  

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.population is not null
order by 2,3



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.population is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



 --Prikazivanje tabelarno


DROP Table if exists #PercentPopulationVaccinated1
Create Table #PercentPopulationVaccinated1
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated1
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated1




Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and dea.population is not null
order by 2,3



Select Location,  MAX(total_vaccinations) as ukupnoVakcinisanih
From PortfolioProject..CovidVaccination
where location in ( 'Slovenia', 'Croatia', 'Bosnia and Herzegovina', 'Serbia', 'Montenegro',
                      'Kosovo', 'North Macedonia', 'Albania')
Group by Location
order by ukupnoVakcinisanih desc

Select Location,  MAX(total_vaccinations_per_hundred) as ukupnoVakcinisanihNaSto
From PortfolioProject..CovidVaccination
where location in ( 'Slovenia', 'Croatia', 'Bosnia and Herzegovina', 'Serbia', 'Montenegro',
                      'Kosovo', 'North Macedonia', 'Albania')
Group by Location
order by ukupnoVakcinisanihNaSto desc

Select Location,  MAX(total_deaths_per_million) as umrlihNaMilion
From PortfolioProject..CovidDeaths
where location in ( 'Slovenia', 'Croatia', 'Bosnia and Herzegovina', 'Serbia', 'Montenegro',
                      'Kosovo', 'North Macedonia', 'Albania')
Group by Location
order by umrlihNaMilion desc

Select Location,  MAX(total_cases_per_million) as zarazenihNaMilion
From PortfolioProject..CovidDeaths
where location in ( 'Slovenia', 'Croatia', 'Bosnia and Herzegovina', 'Serbia', 'Montenegro',
                      'Kosovo', 'North Macedonia', 'Albania')
Group by Location
order by zarazenihNaMilion desc


