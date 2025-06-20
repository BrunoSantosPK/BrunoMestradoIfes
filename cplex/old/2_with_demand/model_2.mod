/* ******************************************************** //
// Nesta versao, o modelo nao permitira que qualquer comida
// utilizada para a alimentacao seja comprada.
// Implementa uma demanda maxima de produtos animais, vegetais
// e carnes, de modo que impossibilite a execucao indefinida
// de um tipo de atividade
// ******************************************************** */

// Carrega dados de entrada do modelo
int total_area = ...; // valor de area total disponivel
int months = ...; // quantidade de meses que serao planejados
int n_plants = ...; // quantidade de cultivos disponiveis para plantacao
int n_animals = ...; // quantidade de animais disponiveis para criacao
int mini_batchs = ...; // quantidade de minilotes
int area_mini_batch = ...; // area em m2 em cada mini lote
int P = ...; // quantidade de pessoas da familia

range I = 0 .. (months - 1); // conjunto de meses
range J = 0 .. (n_plants - 1); // conjunto de plantacoes
range K = 0 .. (n_animals - 1); // conjunto de animais
range L = 0 .. (mini_batchs - 1); // conjunto de mini lotes

int NAC[j in J] = ...; // necessidade alimentar da cultura j em kg / (mes . pessoa)
int NAA[k in K] = ...; // necessidade alimentar da carne do animal k em kg / (mes . pessoa)
int NAP[k in K] = ...; // necessidade alimentar do produto gerado pelo animal k em kg / (mes . pessoa)
int AB[k in K] = ...; // Quantidade de animais em cada lote

float PAC = ...; // valor em R$ / kg do adubo utilizado nas plantacoes
int TCC[j in J] = ...; // tempo em meses que a cultura j leva para estar pronta para colheita
float PYC[j in J] = ...; // quantidade colhida em kg / m2 da cultura j
float VCC[j in J] = ...; // valor em R$ / kg de compra da cultura j
float VVC[j in J] = ...; // valor em R$ / kg de venda da cultura j
float RAC[j in J] = ...; // requisito em kg / (m2 . mes) de adubo que a cultura j necessita
int AAC[j in J][k in K] = ...; // valor binario que indica que a plantacao j pode alimentar o animal k
int TCA[k in K] = ...; // tempo em meses que um animal k precisa para estar pronto para abate
float CCA[k in K] = ...; // custo em R$ / animal de compra do animal k para crescimento
float PRA[k in K] = ...; // valor em R$ / kg da racao do animal k
float VCA[k in K] = ...; // valor em R$ / kg de compra da carne do animal k
float VVA[k in K] = ...; // valor em R$ / kg de venda de um animal k
float RRA[k in K] = ...; // requisito em kg / (animal . mes) de racao necessaria para o animal k
float PYA[k in K] = ...; // massa em kg de um animal k crescido
float RAA[k in K] = ...; // requisito de area em m2 para criar um animal k
int TCP[k in K] = ...; // tempo em meses que um animal k precisa para comecar a gerar produtos
int PYP[k in K] = ...; // quantidade de produto em (unidade especifica) / mes gerada pelo animal k
float VCP[k in K] = ...; // valor em R$ / (unidade especifica) de compra do produto gerado pelo animal k
float AGA[k in K] = ...; // quantidade em kg / (animal . mes) de esterco para adubacao gerado pelo animal k
float VVP[k in K] = ...; // valor em R$ / (unidade especifica) de venda do produto do animal k
float DCC[j in J] = ...; // demanda do cultivo j que pode ser vendido a cada mes
float DPA[k in K] = ...; // demanda de produto do animal k em cada mes
float DCA[k in K] = ...; // demanda de carne do animal k em cada mes

// Variaveis de decisao
dvar boolean LC[l in L][i in I][j in J]; // minilote l ocupado pela plantacao j no mes i
dvar boolean LA[l in L][i in I][k in K]; // minilote l ocupado pelo animal k no mes i
dvar int+ VC[i in I][j in J]; // quantidade em kg do cultivo produzido j vendida no mes i
dvar int+ EC[i in I][j in J]; // quantidade em kg do cultivo produzido j estocado no mes i
dvar int+ CC[i in I][j in J]; // quantidade em kg do cultivo j comprado no mes i
dvar int+ PC[i in I][j in J]; // quantidade em kg do cultivo produzido j que e utilizado para consumo dos moradores no mes i
dvar int+ RC[i in I][j in J][k in K]; // quantidade em kg do cultivo produzido j que sao utilizado para alimentacao do animal k no mes i
dvar int+ FC[i in I]; // quantidade em kg de fertilizante comprado no mes i
dvar int+ CA[i in I][k in K]; // quantidade de lotes do animal k comprados para criacao no mes i
dvar int+ VA[i in I][k in K]; // quantidade de lotes do animal k vendidos no mes i
dvar int+ AA[i in I][k in K]; // quantidade de lotes do animal k abatidos no mes i
dvar int+ PA[i in I][k in K]; // quantidade de carne do animal k comprada para consumo no mes i
dvar int+ RA[i in I][k in K]; // quantidade em kg de racao comprada para o animal k no mes i
dvar int+ VP[i in I][k in K]; // quantidade (unidade especifica) de produto gerado pelo animal k vendido no mes i
dvar int+ AP[i in I][k in K]; // quantidade (unidade especifica) de produto gerado pelo animal k consumido no mes i
dvar int+ CP_[i in I][k in K]; // quantidade (unidade especifica) de produto do animal k comprado no mes i
dvar int+ EA[i in I][k in K]; // quantidade de animais k na propriedade no mes i; variavel intermediaria para facilitar calculos
dvar int+ EF[i in I][j in J]; // quantidade de cultivo j disponivel para uso no tempo i; variavel intermediaria para facilitar calculos

// Funcao objetivo
maximize (
	// Esta e a quantidade de plantacoes colhidas e vendidas em cada mes,
	// sendo TCC o tempo de crescimento, VCC o preco de venda (R$ / kg)
	// da plantacao e VC a quantidade colhida (kg) no mes
	sum(l in L, j in J, i in I: i >= TCC[j]) VCC[j] * VC[i][j]
	
	// Este e o custo de adubacao de cada plantacao, representado de modo
	// geral pela compra de fertilizante (FC, kg) e o preco (PAC, R$/kg)
	- sum(i in I) FC[i] * PAC
	
	// Esta parcela representa o custo de compra de alimentos cultivaveis
	// para suprir a demanda da familia (CC, kg), influenciada pelo preco
	// desses cultivos no mercado (VCC, R$/kg).
	- sum(i in I, j in J) CC[i][j] * VCC[j]
	
	// Este e o custo de compra de cada novo animal, com CA sendo a quantidade
	// de lotes de animais comprados e CCA o custo (R$/lote_animal) de cada animal
	- sum(i in I, k in K) CA[i][k] * CCA[k] * AB[k]
	
	// Esta parcela indica o gasto com racao dos animais, baseada na quantidade
	// de racao comprada (RA, kg) e no preco da racao (PRA, R$/kg).
	- sum(i in I, k in K) RA[i][k] * PRA[k]
	
	// Esta parcela representa a quantidade de produto animal vendido, em que
	// VP (u) e a quantidade de produto animal vendido no mes e VVP o valor de
	// cada produto animal (R$/u).
	+ sum(i in I, k in K) VP[i][k] * VVP[k]
	
	// Esta parcela representa o lucro obtido com a venda de animais, dada pela
	// quantidade vendida (VA, lote_animal) e o preco de venda (VVA, R$/lote_animal)
	+ sum(i in I, k in K) VA[i][k] * VVA[k] * AB[k] * PYA[k]
	
	// Esta parcela indica o custo de se comprar carne animal (PA, kg) para o
	// consumo da familia, poderado pelo custo (VCA, R$/kg).
	- sum(i in I, k in K) PA[i][k] * VCA[k]
	
	// Esta parcela define o custo de compra de produtos animais (CP_, u) para
	// suprir a necessidade da familia, influenciado pelo preco (VCP, R$/u).
	- sum(i in I, k in K) CP_[i][k] * VCP[k]
);

subject to {
  	// Ao longo dos meses animais sao comprados (CA), abatidos para consumo (AA) ou
  	// sao vendidos para o mercado (VA). O balanco de animais sera algo recorrente
  	// nas restricoes, portanto criamos uma variavel para armazenar, a cada mes, a
  	// quantidade de animais que ainda restaram na propriedade (EA).
  	forall(k in K, i in I)
  	  AnimaisRestantesNaPropriedade: EA[i][k] == sum(a in (0 .. i)) (CA[a][k] - AA[a][k] - VA[a][k]);
  	  
  	// Animais so podem ser vendidos ou abatidos apos um tempo de crescimento (TCA),
  	// que representa quantos meses o animal precisa para estar preparado para o caso
  	// de abate (AA) ou venda (VA). Em outras palavras, a venda em um mes qualquer
  	// e limitada ao estoque existente no mes, removidos os animais comprados (CA)
  	// dentro de um periodo de TCA meses. Importante notar o i-TCA[k]+1 que faz a
  	// exclusao da parcela limite, ja que animais comprados em i-TCA[k] podem ser
  	// vendidos ou abatidos.
  	forall(k in K, i in I: i >= TCA[k])
  	  TempoCrescimentoParaAbateVendaAnimais: AA[i][k] + VA[i][k] <= EA[i][k] - sum(a in (i-TCA[k]+1 .. i)) CA[a][k];
  	  
  	// Antes do tempo de crescimento (TCA), nenhum animal pode ser vendido ou abatido
  	forall(k in K, i in I: i < TCA[k])
  	  SemAbateOuVendaAntesDoCrescimento: AA[i][k] + VA[i][k] == 0;
  
	// Toda a ocupacao de cultivos e animais nao deve atingir o maximo de minilotes em
	// periodo de qualquer tempo.
	// Alteracao: incluido o rastreio no tempo de cultivo, fazendo com que a contagem
	// seja feita dentro do tempo de crescimento (TCC) de cada cultivo.
	forall(i in I)
	  LimiteLotesExistentes: sum(l in L, j in J, a in (0..i): a >= i - TCC[j]) LC[l][a][j] + sum(l in L, k in K) LA[l][i][k] <= mini_batchs;
	  
	// Um minilote nao pode ser ocupado simulataneamente pela mesma cultura,
	// assim como nao pode ser ocupado tambem por animais.
	// Para avaliar o espaco de plantacoes, sempre olha no passado de cada lote
	// dentro do range de tempo de crescimento
	//forall(i in I, l in L)
	  //MinilotesSemOcupacaoSimultanea: sum(j in J, a in (0..i): a >= i - TCC[j]) LC[l][a][j] + sum(k in K) LA[l][i][k] <= 1;
	  
	// Quando um minilote for ocupado por uma plantacao, ele passa a nao ser mais alvo de
	// nenhuma outra plantacao durante todo o tempo de crescimento da planta (TCC)
	forall(l in L, j in J, i in I)
	  MiniloteOcupadoDuranteCrescimento: (LC[l][i][j] == 1) => sum(k in K, a in (i..(i+TCC[j])): a < months) (LC[l][a][j] + LA[l][a][k]) == 1;
	  
	// Nem tudo o que for colhido vai ser vendido, parte sera utilizada para o consumo
	// da familia e outra parte sera para consumo animal. Estas partes de consumo sao
	// alocadas dentro da variavel de estoque (EC) enquanto a venda esta em (VC). A
	// quantidade colhida e uma relacao entre os minilotes ocupados (LC), a produtividade
	// do cultivo (kg / m2) e a area de cada minilote.
	forall(j in J, i in I: i >= TCC[j])
	  CultivoColhidoVendidoOuEstocado: EC[i][j] + VC[i][j] == sum(l in L) (LC[l][i-TCC[j]][j] * PYC[j] * area_mini_batch);
	  
	// Para qualquer tempo antes do crescimento nao existe estoque (EC) e nem venda de
	// qualquer cultivo (VC).
	forall(j in J, i in I: i < TCC[j])
	  SemVendaOuEstoqueAntesDoTempo: EC[i][j] + VC[i][j] == 0;
	  
	// Cada mes uma parte do estoque (EC, kg) e consumida pelas familias (PC, kg) ou
	// pelos animais (RC, kg). Porem nao e mandatorio que tudo seja utilizado, o que
	// significa que e possivel guardar estoque para outros meses. Assim, chamamos de
	// estoque efetivo (EF, kg) a quantidade de produto disponivel no mes i, descontada
	// as utilizacoes anteriores.
	forall(j in J, i in I)
	  EstoqueEfetivoDeCultivos: EF[i][j] == sum(a in (0 .. i)) (EC[i][j] - PC[i][j])
	  - sum(k in K, a in (0 .. i)) RC[i][j][k];
	  
	// Uma vez que existe um estoque de produtos colhidos (EF, kg), estes passam a ser
	// disponibilizados para o consumo da familia (PC, kg) ou para o consumo dos
	// animais na propriedade (RC, kg). Assim, o balanco de massa indica que todo o produto
	forall(i in I, j in J)
	  ConsumoFamiliasOuAnimais: PC[i][j] + sum(k in K) RC[i][j][k] <= EF[i][j];
	  
	// Cada cultivo necessita de uma quantidade de adubo para crescer (RAC, kg/m2), que pode
	// ser obtida por meio da compra (FC kg) ou da utilizacao de esterco animal. O esterco e
	// uma "variavel passiva", enquanto existirem animais, sera gerado esterco. Obviamente
	// um animal gera mais esterco quando adulto, porem aqui vamos considerar uma media de
	// esterco gerado por cada animal (AGA, kg/lote_animal).
	forall(i in I)
	  NecessidadeDeAdubacaoDasPlantas: sum(l in L, j in J) (LC[l][i][j] * TCC[j] * RAC[j] * area_mini_batch) <= FC[i]
	  + sum(k in K, a in (0 .. i)) (AGA[k] * EA[a][k] * AB[k]);
	  
	// Em cada mes pode-se comprar animais novos para o crescimento, que ocupam
	// um certo espaco disponivel (minilotes). Esta restricao faz a ligacao entre
	// animais existentes na propriedade e a quantidade de minilotes alocados para
	// criacao de animais.
	forall(k in K, i in I)
	  OcupacaoDeLotesPorAnimais: area_mini_batch * sum(l in L) LA[l][i][k] >= AB[k] * RAA[k] * sum(a in (0 .. i)) EA[a][k];
	  
	// Cada animal, apos um tempo de amadurecimento (TCP), comeca a gerar produtos. Estes produtos
	// podem ser consumidos (AP, u) ou vendidos (VP, u). Dentro de um mes, nenhum produto e estocado.
	forall(k in K, i in I: i >= TCP[k])
	  ConsumoOuVendaDeProdutosAnimais: AP[i][k] + VP[i][k] == AB[k] * PYP[k] * sum(a in (0 .. i-TCP[k])) EA[a][k];
	  
	// Antes de atingir o tempo para gerar produtos, nenhum produto pode ser vendido
	// ou consumido.
	forall(k in K, i in I: i < TCP[k])
	  SemVendaProdutosAntesDoAmadurecimento: VP[i][k] + AP[i][k] == 0;
	  
	// Cada animal possui uma necessidade de racao (RRA, kg/lote_animal), que
	// deve ser suprida por meio da compra de racao (RA, kg) ou da utilizacao
	// dos cultivos estocados (RC, kg). Porem nem todo cultivo pode ser utilizado
	// para a alimentacao animal, informacao obtida pelo bool AAC.
	forall(i in I, k in K)
	  NecessidadeAlimentarDosAnimais: RA[i][k] + sum(j in J: AAC[j][k] == 1) RC[i][j][k] >= AB[k] * EA[i][k] * RRA[k];
	  
	// Os membros da familia (P) possuem uma necessidade alimentar para cada tipo de
	// cultivo (NAC, kg), para carne animal (NAA, kg) e para produtos animais (NAP, u).
	// Esta necessidade pode ser suprida por meio de compras de cultivos (CC, kg),
	// carne animal (PA, kg) e produtos animais (CP_, u) ou por meio do consumo do
	// estoque de cultivos (PC, kg), do abate de animais (AA, lotes_animais) e do
	// consumo de produtos gerados (AP, u).
	forall(i in I, j in J)
	  SegurancaAlimentarPlantacoes: CC[i][j] + PC[i][j] >= P * NAC[j];
	  
	forall(i in I, k in K)
	  SegurancaAlimentarCarneAnimal: PA[i][k] + AA[i][k] * PYA[k] * AB[k] >= P * NAA[k];
	  
	forall(i in I, k in K)
	  SegurancaAlimentarProdutoAnimal: CP_[i][k] + AP[i][k] >= P * NAP[k];
	  
	// Impossibilita que, quando se comecar a ter producoes na fazenda, comida seja
	// comprada para alimentacao da familia
	// Flexibilizando: exige que o estoque de nenhum animal seja 0
	forall(j in J, i in I: i >= TCC[j])
	  SemCompraAposCultivo: CC[i][j] == 0;
	  
	//forall(k in K, i in I: i >= TCP[k])
	  //SemCompraAposAnimaisProduzindo: CP_[i][k] == 0;
	  
	/*forall(j in J, i in I: i >= TCC[j])
	  SemCompraAposCultivo: CC[i][j] == 0;
	  
	forall(k in K, i in I: i >= TCP[k])
	  SemCompraAposAnimaisProduzindo: CP_[i][k] == 0;
	  
	forall(k in K, i in I: i >= TCA[k])
	  SemCompraAposAnimaisAbatidos: PA[i][k] == 0;*/
	  
	// Aplica regras de demanda, impondo um limite maximo do que pode ser vendido
	// e gerado de lucro
	forall(j in J, i in I)
	  DemandaCultivos: VC[i][j] <= DCC[j];
	  
	forall(k in K, i in I)
	  DemandaCarneAnimal: VA[i][k] * PYA[k] * AB[k] <= DCA[k];
	 
	forall(k in K, i in I)
	  DemandaProdutoAnimal: VP[i][k] <= DPA[k];
}

int plants[i in I][j in J] = sum(l in L) LC[l][i][j];
//int animals[i in I] = sum(l in L, k in K) LA[l][i][k];
execute {
  for(var m in I) {
  	writeln("Ocupacao no mes ", m);
  	for(var j in J) {
  	  writeln("Plantacoes ", j, " feitas: ", plants[m][j]);  
  	}
  	writeln("");
  	//writeln("Animais: ", animals[m], "\n");
  }
}
