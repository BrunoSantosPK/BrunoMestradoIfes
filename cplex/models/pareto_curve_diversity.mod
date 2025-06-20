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
	- sum(i in I, j in J: i < TCC[j]) (P * NAC[j] - PC[i][j]) * VCC[j]
	- sum(i in I, k in K: i < TCA[k]) (P * NAA[k] - (AA[i][k] * AB[k] * PYA[k])) * VCA[k]
	- sum(i in I, k in K: i < TCP[k]) (P * NAP[k] - AP[i][k]) * VCP[k]
	
	// Esta parcela inclui o custo de compra de cada animal
	- sum(i in I, k in K) CA[i][k] * CCA[k]
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


// Funcao objetivo
maximize diversity;

subject to {
  // Estas restricoes fazem calculos auxiliares para a funcao objetivo, calculando
  // as alocacoes em cada periodo para calculo do indice de gini
  forall(i in I, j in J) {
    aXT[i][j] == sum(l in L, a in ((i-TCC[j])..i): a >= 0) LC[l][a][j] / mini_batchs;
  }    
  forall(i in I)
    aLT[i] == sum(l in L, j in J, a in ((i-TCC[j])..i): a >= 0) LC[l][a][j];
  
  // Estas restricoes possuem como objetivo identificar a quantidade de animais
  // existentes na fazenda em termos totais (aAT), animais produzindo (aAP) e
  // animais que podem ser vendidos ou abatidos (aAC).
  forall(k in K, i in I) {
    aAT[i][k] == sum(a in (0 .. i)) (CA[a][k] - AA[a][k] - VA[a][k]);
    aAP[i][k] == sum(a in (0..i): a <= i - TCP[k]) CA[a][k] - sum(a in (0..i)) (AA[a][k] + VA[a][k]);
    aAC[i][k] == sum(a in (0..i): a <= i - TCA[k]) CA[a][k] - sum(a in (0..i)) (AA[a][k] + VA[a][k]);
  }
  
  // Os animais da propriedade precisam de um espaco de area para sobreviverem,
  // que e dado pelo requisito de cada animal (RAA). Cada lote possui uma quantidade
  // especifica de animal (AB) e a contagem de estoque de animais (aAT) informa quanto
  // de area sera preciso dos minilotes (LA), convertidos por meio da area de cada
  // minilote (area_mini_batch).
  forall(i in I, k in K)
    sum(l in L) LA[l][i][k] * area_mini_batch >= RAA[k] * AB[k] * aAT[i][k];
  
  // Quando uma plantacao e realizada, um lote precisa ser ocupado e deve permanecer
  // sem ocupacao por animais ou outras plantacoes ate a hora da colheita.
  // Importante: considero aqui que no tempo i+TCC[j] o minilote pode ser utilizado
  // para outros cultivos ou animais, ja que se passou um tempo TCC[j].  
  forall(l in L, i in I)
    sum(j in J, a in (i .. (i+TCC[j]-1)): a < months) LC[l][a][j] + sum(k in K) LA[l][i][k] <= 1;
  
  // Todas as atividades que demandam area precisam obedecer o limite de lotes existentes
  forall(i in I)
    sum(l in L, k in K) LA[l][i][k] + sum(l in L, j in J,  a in ((i-TCC[j])..i): a >= 0) LC[l][a][j] <= mini_batchs;
  
  // Cada plantacao necessita de uma quantidade de adubo (RAC), que sera entregue pelo
  // esterco dos animais (AGA).
  forall(i in I)
    sum(k in K) aAT[i][k] * AB[k] * AGA[k] >= sum(j in J, l in L, a in ((i-TCC[j])..i): a >= 0) (RAC[j] * LC[l][a][j]);
  
  // Ao realizar a colheita, parte e utilizada para venda (VC) e parte e estocada (EC),
  // sendo a quantidade colhida dependente dos lotes plantados (LC) em i-TCC.
  // Importante ponderar que nao existe colheita antes de um tempo minimo de crescimento
  // (TCC), logo estoque e venda devem ser zerados. Tamb�m, a quantidade vendida nao
  // pode ser superior a demanda existente no mercado (DCC).
  forall(i in I, j in J: i >= TCC[j])
    EC[i][j] + VC[i][j] == sum(l in L) (LC[l][i-TCC[j]][j] * PYC[j] * area_mini_batch);
    
  forall(i in I, j in J: i < TCC[j])
    EC[i][j] + VC[i][j] == 0;
    
  forall(i in I, j in J)
    VC[i][j] <= DCC[j];
    
  // Uma vez que se e estocado algum cultivo, ele passa a ser consumido pelos membros
  // da familia (PC) ou sao dados como racao para animais (RC). Assim, a variavel de
  // auxilio aEC determina a quantidade de cultivo esta disponivel para estes usos
  // em cada instante de tempo i.
  forall(j in J, i in I)
    aEC[i][j] == sum(a in (0 .. i)) (EC[i][j] - PC[i][j]) - sum(k in K, a in (0 .. i)) RC[i][j][k];
    
  // O estoque de cultivos (EC) e utilizado para consumo das familias (PC) ou para
  // alimentacao dos animais (RC).
  forall(i in I, j in J)
    PC[i][j] + sum(k in K) RC[i][j][k] <= aEC[i][j];
    
  // Os cultivos colhidos devem suprir a demenda dos membros da familia (NAC) e dos
  // animais (RRA), salvo que animais podem ser alimentados com racao (RA).
  forall(j in J, i in I: i > TCC[j])
    PC[i][j] >= NAC[j] * P;
    
  forall(k in K, i in I)
    RA[i][k] + sum(j in J: AAC[j][k] == 1) RC[i][j][k] >= AB[k] * aAT[i][k] * RRA[k];
    
  // Os animais existentes e capazes de gerar produtos (aAP) geram todo mes
  // uma quantidade de produtos que podem ser vendidos (VP) ou consumidos
  // pelos membros da familia para suprir a demanda alimentar (NAP).
  // Importante: existe um limite de venda (DPA), uma vez que o pequeno agricultor
  // nao e capaz de escoar uma producao grande.
  forall(k in K, i in I) {
    VP[i][k] + AP[i][k] == aAP[i][k] * AB[k] * PYP[k];
    VP[i][k] <= DPA[k];
  }    
  
  // Importante: antes do tempo de crescimento (TCP) nao e possivel que se
  // tenham produtos para vender ou consumir.
  forall(k in K, i in I: i >= TCP[k])
    AP[i][k] >= P * NAP[k];
    
  // Os animais apos um tempo de amadurecimento (TCA) estao prontos para serem abatidos
  // e consumidos (AA) ou vendidos para abate (VA). A quantidade de animais que podem
  // ser vendidos ou abatidos e o estoque efetivo de abate (aAC).
  forall(k in K, i in I) {
    VA[i][k] + AA[i][k] <= aAC[i][k];
    VA[i][k] * AB[k] * PYA[k] <= DCA[k];
  }
  
  forall(k in K, i in I: i < TCA[k]) {
    VA[i][k] == 0;
    AA[i][k] == 0;
  }    
  
  // Importante: os membros da familia tambem possuem uma necessidade de consumo
  // de carne animal (NAA) que deve ser suprida pelos animais abatidos (AA); porem
  // nao existe abata antes do tempo de amadurecimento (TCA).
  forall(k in K, i in I: i >= TCA[k])
    AA[i][k] * AB[k] * PYA[k] >= NAA[k];
    
  // Restrição da Curva de Pareto
  // Limita o minimo de Lucro desejado
  profit >= 280000;
  
  // Restrição da Curva de Pareto
  // Limita o minimo de Segurança Alimentar desejada
  food_security >= 50;
  
  // Restrição da Curva de Pareto
  // Limita o minimo de Diversidade desejada
  // diversity >= 0.31;
 
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
}
