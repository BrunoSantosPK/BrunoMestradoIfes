/* ******************************************************** //
// Este modelo parte da necessidade de simplificacao das
// restricoes e variaveis de decisao.
// Alteracoes executadas:
// 1. Remocao da possibilidade de comprar fertilizante,
// fazendo com que a integracao seja a unica opcao.
// 2. Para a cabra, o tempo de amadurecimento e o tempo de
// geracao de produtos foi igualado, para evitar um balanco
// adicional e um rastreio de lotes.
// 3. Os custos relacionados com a compra de comida foram
// movidos para a funcao objetivo, no intuito de remover a
// possibilidade de compra e, por consequencia, evitar a
// solucao de monocultura.
// ******************************************************** */

// Carrega dados de entrada do modelo
int total_area = ...; // valor de area total disponivel
int months = ...; // quantidade de meses que serao planejados
int n_plants = ...; // quantidade de cultivos disponiveis para plantacao
int n_animals = ...; // quantidade de animais disponiveis para criacao
int mini_batchs = ...; // quantidade de minilotes
int area_mini_batch = ...; // area em m2 em cada mini lote
int P = ...; // quantidade de pessoas da familia
// float budget = ...; // orcamento inical para suprir custos

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
dvar int+ PC[i in I][j in J]; // quantidade em kg do cultivo produzido j que e utilizado para consumo dos moradores no mes i
dvar int+ RC[i in I][j in J][k in K]; // quantidade em kg do cultivo produzido j que sao utilizado para alimentacao do animal k no mes i
dvar int+ CA[i in I][k in K]; // quantidade de lotes do animal k comprados para criacao no mes i
dvar int+ VA[i in I][k in K]; // quantidade de lotes do animal k vendidos no mes i
dvar int+ AA[i in I][k in K]; // quantidade de lotes do animal k abatidos no mes i
dvar int+ RA[i in I][k in K]; // quantidade em kg de racao comprada para o animal k no mes i
dvar int+ VP[i in I][k in K]; // quantidade (unidade especifica) de produto gerado pelo animal k vendido no mes i
dvar int+ AP[i in I][k in K]; // quantidade (unidade especifica) de produto gerado pelo animal k consumido no mes i

// Variaveis de decisao auxiliares
dvar int+ aAT[i in I][k in K]; // quantidade total de lotes do animal k no tempo i
dvar int+ aAP[i in I][k in K]; // quantidade de lotes do animal k no tempo i que podem gerar produtos
dvar int+ aAC[i in I][k in K]; // quantidade de lotes do animal k no tempo i que podem ser abatidos ou vendidos
dvar int+ aEC[i in I][j in J]; // quantidade do cultivo j disponivel para utilizacao no tempo i
dvar float aLT[i in I];
dvar float aXT[i in I][j in J];

// dvar float aBudget[i in I];
// dvar float aRevenue[i in I];
// dvar float aCost[i in I];


// Funcoes de avaliacao
dexpr float profit = (
	// Esta e a quantidade de plantacoes colhidas e vendidas em cada mes,
	// sendo TCC o tempo de crescimento, VCC o preco de venda (R$ / kg)
	// da plantacao e VC a quantidade colhida (kg) no mes
	sum(l in L, j in J, i in I: i >= TCC[j]) VVC[j] * VC[i][j]
	
	// Esta parcela representa o gasto com a compra de racao para alimentar
	// os animais existentes na propriedade
	- sum(i in I, k in K) RA[i][k] * PRA[k]
	
	// Esta parcela representa o ganho obtido quando os produtos animais
	// sao vendidos (VP) e nao consumidos
	+ sum(i in I, k in K) VP[i][k] * VVP[k]
	
	// Esta parcela representa o ganho obtido ao se vender animais (AA)
	// para o mercado no lugar de mante-los produzindo ou come-los.
	+ sum(i in I, k in K) VA[i][k] * AB[k] * PYA[k] * VVA[k]
	
	// Esta parcela inclui o custo de manter a seguranca alimentar dos
	// membros da familia antes que se comece a gerar cultivos, produtos
	// animais e carne dentro da propriedade.
	/*- sum(i in I, j in J: i < TCC[j]) (P * NAC[j] - PC[i][j]) * VCC[j]
	- sum(i in I, k in K: i < TCA[k]) (P * NAA[k] - (AA[i][k] * AB[k] * PYA[k])) * VCA[k]
	- sum(i in I, k in K: i < TCP[k]) (P * NAP[k] - AP[i][k]) * VCP[k]*/
	
	// Esta parcela inclui o custo de compra de cada animal
	- sum(i in I, k in K) CA[i][k] * CCA[k] * AB[k]
);

dexpr float food_security = (
	sum(i in I) sum(j in J) (PC[i][j] - NAC[j] * P) / sum(j in J) (NAC[j] * months * P)
	
	+ sum(i in I) sum(k in K) (AP[i][k] - P * NAP[k]) / sum(k in K) (NAP[k] * months * P)
	
	+ sum(i in I) sum(k in K) (AA[i][k] * AB[k] * PYA[k] - P * NAA[k]) / sum(k in K) (NAA[k] * months * P)
);

dexpr float diversity = (
	// Esta secao tem como finalidade incluir a parte de diversidade,
	// pontuando a obtencao de uma maior variedade de plantio
	// Definir x como a porcentagem de ocupacao de lotes da cultura j
	// no tempo i
	sum(i in I, a in J) (2 * n_plants * aXT[i][a]) - sum(i in I, a in J) sum(b in J) abs(aXT[i][a] - aXT[i][b])
);

dexpr float diversity_gini = sum(i in I, a in J) sum(b in J) abs(aXT[i][a] - aXT[i][b]) / sum(i in I, a in J) (2 * n_plants * aXT[i][a]);


// Funcao objetivo
maximize food_security;

subject to {
  // Faz o cálculo do dinheiro existente para utilização
  /*forall(i in I) {
    aRevenue[i] ==
    	sum(l in L, j in J) VVC[j] * VC[i][j]
    	+ sum(k in K) VP[i][k] * VVP[k]
    	+ sum(k in K) VA[i][k] * AB[k] * PYA[k] * VVA[k];
    	
    aCost[i] ==
    	sum(k in K) RA[i][k] * PRA[k]
    	+ sum(k in K) CA[i][k] * CCA[k] * AB[k];
    
  	aBudget[i] ==
  		budget
  		+ sum(a in (0..(i-1))) aRevenue[a]
  		- sum(a in (0..(i-1))) aCost[a];
  		
  	aCost[i] <= aBudget[i];
  }*/
  
  // Estas restricoes fazem calculos auxiliares para a funcao objetivo, calculando
  // as alocacoes em cada periodo para calculo do indice de gini
  forall(i in I, j in J) {
    aXT[i][j] == sum(l in L, a in ((i-TCC[j])..i): a >= 0) LC[l][a][j] / mini_batchs;
  }    
  forall(i in I)
    LotesOcupadosPorCultivosTotais: aLT[i] == sum(l in L, j in J, a in ((i-TCC[j])..i): a >= 0) LC[l][a][j];
  
  // Estas restricoes possuem como objetivo identificar a quantidade de animais
  // existentes na fazenda em termos totais (aAT), animais produzindo (aAP) e
  // animais que podem ser vendidos ou abatidos (aAC).
  forall(k in K, i in I) {
    EstoqueTotalDeAnimais: aAT[i][k] == sum(a in (0 .. i)) (CA[a][k] - AA[a][k] - VA[a][k]);
    EstoqueDeAnimaisProduzindo: aAP[i][k] == sum(a in (0..i): a <= i - TCP[k]) CA[a][k] - sum(a in (0..i)) (AA[a][k] + VA[a][k]);
    EstoqueDeAnimaisParaAbate: aAC[i][k] == sum(a in (0..i): a <= i - TCA[k]) CA[a][k] - sum(a in (0..i)) (AA[a][k] + VA[a][k]);
  }
  
  // Os animais da propriedade precisam de um espaco de area para sobreviverem,
  // que e dado pelo requisito de cada animal (RAA). Cada lote possui uma quantidade
  // especifica de animal (AB) e a contagem de estoque de animais (aAT) informa quanto
  // de area sera preciso dos minilotes (LA), convertidos por meio da area de cada
  // minilote (area_mini_batch).
  forall(i in I, k in K)
    AreaNecessariaParaAnimais: sum(l in L) LA[l][i][k] * area_mini_batch >= RAA[k] * AB[k] * aAT[i][k];
  
  // Quando uma plantacao e realizada, um lote precisa ser ocupado e deve permanecer
  // sem ocupacao por animais ou outras plantacoes ate a hora da colheita.
  // Importante: considero aqui que no tempo i+TCC[j] o minilote pode ser utilizado
  // para outros cultivos ou animais, ja que se passou um tempo TCC[j].  
  forall(l in L, i in I)
    MiniloteNaoOcupadoPorVariosCultivosNemAnimais: sum(j in J, a in (i .. (i+TCC[j]-1)): a < months) LC[l][a][j] + sum(k in K) LA[l][i][k] <= 1;
  
  // Todas as atividades que demandam area precisam obedecer o limite de lotes existentes
  forall(i in I)
    OcupacaoMaxima: sum(l in L, k in K) LA[l][i][k] + sum(l in L, j in J,  a in ((i-TCC[j])..i): a >= 0) LC[l][a][j] <= mini_batchs;
  
  // Cada plantacao necessita de uma quantidade de adubo (RAC), que sera entregue pelo
  // esterco dos animais (AGA).
  forall(i in I)
    QuantidadeEstercoGeradoUtilizado: sum(k in K) aAT[i][k] * AB[k] * AGA[k] >= sum(j in J, l in L, a in ((i-TCC[j])..i): a >= 0) (RAC[j] * LC[l][a][j]);
  
  // Ao realizar a colheita, parte e utilizada para venda (VC) e parte e estocada (EC),
  // sendo a quantidade colhida dependente dos lotes plantados (LC) em i-TCC.
  // Importante ponderar que nao existe colheita antes de um tempo minimo de crescimento
  // (TCC), logo estoque e venda devem ser zerados. Tambem, a quantidade vendida nao
  // pode ser superior a demanda existente no mercado (DCC).
  forall(i in I, j in J: i >= TCC[j])
    ColheitaEstocadaOuVendida: EC[i][j] + VC[i][j] == sum(l in L) (LC[l][i-TCC[j]][j] * PYC[j] * area_mini_batch);
    
  forall(i in I, j in J: i < TCC[j])
    SemColheitaAntesDoTempo: EC[i][j] + VC[i][j] == 0;
    
  forall(i in I, j in J)
    DemandaMaximaCultivos: VC[i][j] <= DCC[j];
    
  // Uma vez que se e estocado algum cultivo, ele passa a ser consumido pelos membros
  // da familia (PC) ou sao dados como racao para animais (RC). Assim, a variavel de
  // auxilio aEC determina a quantidade de cultivo esta disponivel para estes usos
  // em cada instante de tempo i.
  forall(j in J, i in I)
    EstoqueEfetivoDeCultivos: aEC[i][j] == sum(a in (0 .. i)) (EC[i][j] - PC[i][j]) - sum(k in K, a in (0 .. i)) RC[i][j][k];
    
  // O estoque de cultivos (EC) e utilizado para consumo das familias (PC) ou para
  // alimentacao dos animais (RC).
  forall(i in I, j in J)
    ConsumoFamiliasOuAnimais: PC[i][j] + sum(k in K) RC[i][j][k] <= aEC[i][j];
    
  // Os cultivos colhidos devem suprir a demenda dos membros da familia (NAC) e dos
  // animais (RRA), salvo que animais podem ser alimentados com racao (RA).
  forall(j in J, i in I: i > TCC[j])
    SegurancaAlimentarCultivos: PC[i][j] >= NAC[j] * P;
    
  forall(k in K, i in I)
    RacaoDosAnimais: RA[i][k] + sum(j in J: AAC[j][k] == 1) RC[i][j][k] >= AB[k] * aAT[i][k] * RRA[k];
    
  // Os animais existentes e capazes de gerar produtos (aAP) geram todo mes
  // uma quantidade de produtos que podem ser vendidos (VP) ou consumidos
  // pelos membros da familia para suprir a demanda alimentar (NAP).
  // Importante: existe um limite de venda (DPA), uma vez que o pequeno agricultor
  // nao e capaz de escoar uma producao grande.
  forall(k in K, i in I) {
    ProdutosVendidosOuConsumidos: VP[i][k] + AP[i][k] == aAP[i][k] * AB[k] * PYP[k];
    DemandaMaximaProdutosAnimais: VP[i][k] <= DPA[k];
  }    
  
  // Importante: antes do tempo de crescimento (TCP) nao e possivel que se
  // tenham produtos para vender ou consumir.
  forall(k in K, i in I: i >= TCP[k])
    SegurancaAlimentarProdutosAnimais: AP[i][k] >= P * NAP[k];
    
  // Os animais apos um tempo de amadurecimento (TCA) estao prontos para serem abatidos
  // e consumidos (AA) ou vendidos para abate (VA). A quantidade de animais que podem
  // ser vendidos ou abatidos e o estoque efetivo de abate (aAC).
  forall(k in K, i in I) {
    EstoqueDisponivelAnimaisMaduros: VA[i][k] + AA[i][k] <= aAC[i][k];
    DemandaMaximaCarneAnimal: VA[i][k] * AB[k] * PYA[k] <= DCA[k];
  }
  
  forall(k in K, i in I: i < TCA[k]) {
    SemVendaAntesDoCrescimento: VA[i][k] == 0;
    SemAbateAntesDoCrescimento: AA[i][k] == 0;
  }    
  
  // Importante: os membros da familia tambem possuem uma necessidade de consumo
  // de carne animal (NAA) que deve ser suprida pelos animais abatidos (AA); porem
  // nao existe abata antes do tempo de amadurecimento (TCA).
  forall(k in K, i in I: i >= TCA[k])
    SegurancaAlimentarCarneAnimal: AA[i][k] * AB[k] * PYA[k] >= NAA[k] * P;
 
}

// Script para visualizacao de resultado
int animals[i in I] = sum(l in L, k in K) LA[l][i][k];
int cultives[i in I] = sum(l in L, j in J, a in (i-TCC[j] .. i): a >= 0) LC[l][a][j];
float mean_batch = sum(i in I) (animals[i] + cultives[i]) / (months * mini_batchs);
float mean_animals = sum(i in I) (animals[i]) / (months * mini_batchs);
float mean_cultives = sum(i in I) (cultives[i]) / (months * mini_batchs);

execute {
  
  writeln("Ocupacao media: ", mean_batch);
  writeln("Ocupacao animais: ", mean_animals);
  writeln("Ocupacao cultivos: ", mean_cultives);
  writeln("Lucro obtido: ", profit);
  writeln("Seguranca alimentar: ", food_security);
  writeln("Diversidade: ", diversity);
  writeln("Gini: ", diversity_gini);
  
  // Cria os arquivos para salvar dados
  var vc_file = new IloOplOutputFile("../csv/vc_s11.csv");
  vc_file.writeln("i,j,vc_value");
  
  var ec_file = new IloOplOutputFile("../csv/ec_s11.csv");
  ec_file.writeln("i,j,ec_value");
  
  var pc_file = new IloOplOutputFile("../csv/pc_s11.csv");
  pc_file.writeln("i,j,pc_value");
  
  var ca_file = new IloOplOutputFile("../csv/ca_s11.csv");
  ca_file.writeln("i,k,ca_value");
  
  var va_file = new IloOplOutputFile("../csv/va_s11.csv");
  va_file.writeln("i,k,va_value");
  
  var aa_file = new IloOplOutputFile("../csv/aa_s11.csv");
  aa_file.writeln("i,k,aa_value");
  
  var ra_file = new IloOplOutputFile("../csv/ra_s11.csv");
  ra_file.writeln("i,k,ra_value");
  
  var vp_file = new IloOplOutputFile("../csv/vp_s11.csv");
  vp_file.writeln("i,k,vp_value");
  
  var ap_file = new IloOplOutputFile("../csv/ap_s11.csv");
  ap_file.writeln("i,k,ap_value");
  
  var rc_file = new IloOplOutputFile("../csv/rc_s11.csv");
  rc_file.writeln("i,j,k,rc_value");
  
  var lc_file = new IloOplOutputFile("../csv/lc_s11.csv");
  lc_file.writeln("l,i,j,lc_value");
  
  var la_file = new IloOplOutputFile("../csv/la_s11.csv");
  la_file.writeln("l,i,k,la_value");
  
  for(var i in I) {
    // Organiza o salvamento de dados de dimensões I x J
  	for(var j in J) {
  		vc_file.writeln(i + "," + j + "," + VC[i][j]);
  		ec_file.writeln(i + "," + j + "," + EC[i][j]);
  		pc_file.writeln(i + "," + j + "," + PC[i][j]);
  		
  		// Organiza o salvamento de dados de dimensões I x J x K
  		for(var k in K) {
  			rc_file.writeln(i + "," + j + "," + k + "," + RC[i][j][k]);
  		}
  	}
  	
  	// Organiza o salvamento de dados de dimensões I x K
  	for(var k in K) {
  		ca_file.writeln(i + "," + k + "," + CA[i][k]);
  		va_file.writeln(i + "," + k + "," + VA[i][k]);
  		aa_file.writeln(i + "," + k + "," + AA[i][k]);
  		ra_file.writeln(i + "," + k + "," + RA[i][k]);
  		vp_file.writeln(i + "," + k + "," + VP[i][k]);
  		ap_file.writeln(i + "," + k + "," + AP[i][k]);
  	}
  }
  
  // Organiza o salvamento de dados de dimensões L x I x J
  for(var l in L) {
  	for(var i in I) {
  		for(var j in J) {
  			lc_file.writeln(l + "," + i + "," + j + "," + LC[l][i][j]);
  		}
  		
  		for(var k in K) {
  			la_file.writeln(l + "," + i + "," + j + "," + LA[l][i][k]);
  		}
  	}
  }
  
  // Fecha todos os arquivos
  vc_file.close();
  ec_file.close();
  pc_file.close();
  ca_file.close();
  va_file.close();
  aa_file.close();
  ra_file.close();
  vp_file.close();
  ap_file.close();
  rc_file.close();
  lc_file.close();
  la_file.close();

}
