# ��������� ���� ������� � � �
# �������� ��2

rm(list = ls())

options("max.print" = 50)
getOption

# ���������
# ���-�� ��������� (����� �� �������)
n <- 5000
# ������� ����������
alpha <- 0.05
quant <- qnorm(1 - alpha / 2)
# ����������� ����� �� ������
pcont <- pksi <- 0.1
pexp <- peta <- 0.1
# �������������� �������
ksi <- eta <- 0

# �������� ����������� ��� ������� ������ "begin" � ������
begin <- 100

# ������� ��������� � ����������� ���������� �� �������
chiSNumerator <- 0
chiSDenominator <- 0

# �������������� ������
whos <- 0
# ������� ������� ����� ������
ksiIndex <- 0
etaIndex <- 0
# ������� i ���������� ����� (��� ��������)
testIndicator <- 0
# ������ ������ ������ ���������� � ������ (��� ��������)
counterNumeratorDenominator <- 0

se <- 0
z <- 0
pVal <- 0
upperConf <- 0

# �������� ����
for (i in 1 : (2 * n)) {
        # ���������� ������ �� � � �
        # ���� whos = 1, i-e �������� ����������� � ������ ksi
        # ���� whos = 2, i-e �������� ����������� � ������ eta
        whos <- sample(c(1, 2), 1, replace = T, prob = c(0.5, 0.5))
        
        if (whos == 1) {
                ksiIndex <- ksiIndex + 1    
                ksi[ksiIndex] <- sample(c(0, 1), 1, replace = T, 
                                        prob = c(1 - pksi, pksi))
        } else if (whos == 2) {
                etaIndex <- etaIndex + 1
                eta[etaIndex] <- sample(c(0, 1), 1, replace = T, 
                                        prob = c(1 - peta, peta))
        }
        
        testIndicator <- testIndicator + 1
        
        # ���������� ��2 ��������� �� ������ ������ ����
        if ((min(ksiIndex, etaIndex) >= begin) &
            (((testIndicator / 2) - round(testIndicator / 2)) == 0)) {
                
                ppoolemp <- (sum(ksi[1 : ksiIndex]) + sum(eta[1 : etaIndex])) /
                        (length(ksi[1 : ksiIndex]) + length(eta[1 : etaIndex]))
                
                # ������
                counterNumeratorDenominator <- counterNumeratorDenominator + 1
                
                # ��������� ����������
                chiSNumerator[counterNumeratorDenominator] <- 
                        sum(ksi[1 : ksiIndex]) / length(ksi[1 : ksiIndex]) - 
                        sum(eta[1 : etaIndex]) / length(eta[1 : etaIndex])
                
                # ����������� ����������
                chiSDenominator[counterNumeratorDenominator] <- 
                        sqrt(ppoolemp * (1 - ppoolemp) * 
                                (1 / length(ksi[1 : ksiIndex]) + 
                                 1 / length(eta[1 : etaIndex])) + 
                                0.000000000001^2)
                se[counterNumeratorDenominator] <- chiSNumerator[counterNumeratorDenominator] /
                        chiSDenominator[counterNumeratorDenominator]
                # z[counterNumeratorDenominator] <- quant * 
                        # se[counterNumeratorDenominator]
                pVal[counterNumeratorDenominator] <- 2*pnorm(se[counterNumeratorDenominator], 
                                                           lower.tail = TRUE)
                upperConf[counterNumeratorDenominator] <- quant * 
                        chiSDenominator[counterNumeratorDenominator]
        }
}

# plot(sort(pVal), type = 'l')
# abline(h = alpha)
# 
# # ���������� ���������� �������� H0 ��� pval < alpha
# length(which(pVal <= alpha))
# # ���������� ���������� �������� H0 ��� Xi2 > Z(1-alpha/2)
# length(which(abs(se) >= quant))
# # ���������� ���������� �������� H0 ��� ������ �� ������������� ��������
# length(which(chiSNumerator >= confLevels$upper))
# length(which(chiSNumerator <= confLevels$lower))

# ������������� �������� (-z*SE; z*SE) 
upperConf2 <- qnorm(1 - alpha / 2) * chiSDenominator
sum(upperConf == upperConf2)
length(upperConf2)

lowerConf <- - upperConf

# ������������� �������� ��� �������� dEmp (Udacity)
# (�� ������� �� �������� (����� ��������� - ��� ������ � ����� ���������))
upperConfdEmp <- chiSNumerator + qnorm(1 - alpha / 2) * chiSDenominator
lowerConfdEmp <- chiSNumerator - qnorm(1 - alpha / 2) * chiSDenominator

# ������ � ������ (��� ��������)
confLevels <- list(upperConf, lowerConf, upperConfdEmp, lowerConfdEmp)
names(confLevels)[[1]] <- 'upper'
names(confLevels)[[2]] <- 'lower'
names(confLevels)[[3]] <- 'upperdEmp'
names(confLevels)[[4]] <- 'lowerdEmp'

# ������� ������ I ����
# typeIErrorRate <- cumsum((abs(chiSNumerator) > confLevels$upper) * TRUE) /
#         cumsum(rep(1, length(chiSNumerator)))

# ��������� ��������
lwd.plot <- 1
start <- 1
finish <- max(length(ksi), length(eta))
limX <- finish
limY <- max(confLevels$upper, na.rm = T)


# ������ ��������� (pksiEmp - petaEmp)
plot(chiSNumerator[start:limX], t='l', col='Blue', lwd = lwd.plot,
     lab = c(20, 20, 5),
     las = 0,
     xlim = c(0,limX), ylim = c(- limY, limY), 
     xlab = 'Visitors per group', 
     ylab = 'Conversion Rate Difference',
     main = 'Confidence Interval for Conversion Rate Difference'
)

# ��� �������� (-qvantile*SE; qvantile*SE)
lines(confLevels$upper, col = 'Red', lwd = 1)
lines(confLevels$lower, col = 'Red', lwd = 1)

# ��� ��, ��
abline(h = 0)
abline(v = 0)

library(pwr)
pwr <- power.prop.test(p1 = pksi, p2 = ifelse(peta-pksi!=0, pet, pksi+0.02), 
                       sig.level = 0.05,
                       power = 0.8,
                       alternative = c("two.sided"),
                       strict = FALSE)

# ����������� ���-�� ����������� n (� ����� ������)
abline(v = pwr$n, col = "red", lty = 5)
text((pwr$n+650), -0.06, paste("n = ", round(pwr$n))) 

# pwr.2p.test(h = , n = , sig.level =, power = )
# pwr.2p.test(h = 0.02, n = 3533, sig.level = alpha)
# 
# pwr.p.test(h = , n = , sig.level = power = )
# pwr.p.test(h = 0.02, sig.level = alpha, power = 1 - 0.2)
# 
# pwr.chisq.test(w =, N = , df = , sig.level =, power = )
# pwr.chisq.test(w = 0.02, N = 3533, df = 3531, sig.level = alpha)
# 
# pwr.t2n.test(n1 = , n2= , d = , sig.level =, power = )
# pwr.t.test(3533, d = 0.02, sig.level = alpha)
# 
# power.prop.test(p1=8/200, p2=60/2000, power=0.8, sig.level=0.05)
# power.prop.test(p1=pksi, p2=pksi+0.02, power=0.8, sig.level=0.05)
# 
# ?power.t.test
# power.t.test(delta=0.02, sd=0.3, power=0.8, alternative = "two.sided")
# power.t.test(delta=0.02, sd=0.3, power=0.8, alternative = "two.sided", 
#              type = "two.sample")


