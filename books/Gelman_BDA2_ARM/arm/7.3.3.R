congress <- vector ("list", 49)
for (i in 1:49){
  year <- 1896 + 2*(i-1)
  file <- paste ("../doc/gelman/arm2/cong3/", year, ".asc", sep="")
  data.year <- matrix (scan (file), byrow=TRUE, ncol=5)
  data.year <- cbind (rep(year, nrow(data.year)), data.year)
  congress[[i]] <- data.year
}

# Note: download all ".asc" files into your R working directory in a file
# named cong3 for the above command to work

i86 <- (1986-1896)/2 + 1
cong86 <- congress[[i86]]
cong88 <- congress[[i86+1]]
cong90 <- congress[[i86+2]]

v86 <- cong86[,5]/(cong86[,5]+cong86[,6])
bad86 <- cong86[,5]==-9 | cong86[,6]==-9
v86[bad86] <- NA
contested86 <- v86>.1 & v86<.9
inc86 <- cong86[,4]

v88 <- cong88[,5]/(cong88[,5]+cong88[,6])
bad88 <- cong88[,5]==-9 | cong88[,6]==-9
v88[bad88] <- NA
contested88 <- v88>.1 & v88<.9
inc88 <- cong88[,4]

v90 <- cong90[,5]/(cong90[,5]+cong90[,6])
bad90 <- cong90[,5]==-9 | cong90[,6]==-9
v90[bad90] <- NA
contested90 <- v90>.1 & v90<.9
inc90 <- cong90[,4]

jitt <- function (x,delta) {x + runif(length(x), -delta, delta)}

## Fitting the model

v86.adjusted <- ifelse (v86<.1, .25, ifelse (v86>.9, .75, v86))
vote.86 <- v86.adjusted[contested88]
incumbency.88 <- inc88[contested88]
vote.88 <- v88[contested88]

library ("arm")
fit.88 <- lm (vote.88 ~ vote.86 + incumbency.88)
display (fit.88)

v86.adjusted <- ifelse (v86<.1, .25, ifelse (v86>.9, .75, v86))
vote.86 <- v86.adjusted[contested88]
vote.88 <- v88[contested88]
incumbency.88 <- inc88[contested88]

## Simulation for inferences and predictions of new data points

incumbency.90 <- inc90
vote.88 <- v88
n.tilde <- length (vote.88)
X.tilde <- cbind (rep (1, n.tilde), vote.88, incumbency.90)

n.sims <- 1000
sim.88 <- sim (fit.88, n.sims)
y.tilde <- array (NA, c(n.sims, n.tilde))
for (s in 1:n.sims){
  pred <- X.tilde %*% sim.88$coef[s,]
  ok <- !is.na(pred)
  y.tilde[s,ok] <- rnorm (sum(ok), pred[ok], sim.88$sigma[s])
}

## Predictive simulation for a nonlinear function of new data

y.tilde.new <- ifelse (is.na(y.tilde), 0, y.tilde)

dems.tilde <- rep (NA, n.sims)
for (s in 1:n.sims){
  dems.tilde[s] <- sum (y.tilde.new[s,] > .5)
}

print (dems.tilde)
print (mean(dems.tilde))
print (sd(dems.tilde))

