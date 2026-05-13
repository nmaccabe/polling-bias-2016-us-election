################################################################################
#                                                                              #
#                            Load R Libraries                                  #
#                                                                              #
################################################################################
# install.packages(c("ggplot2", "lubridate", "dplyr", "moments", "Hmisc", "stargazer", "dslabs", "maps"), dependencies = TRUE)
library(ggplot2)
library(lubridate)
library(dplyr)
library(moments)
library(Hmisc)
library(stargazer)
library(dslabs)
library(maps)
################################################################################
#                                                                              #
#                         Set your working directory                           #
#                                                                              #
################################################################################

working_directory <- dirname(rstudioapi::documentPath())
setwd(working_directory)


# ── 1. Load Data ──────────────────────────────────────────────────────────────
#df <- read.csv("../data/polls_us_election_2016.csv", stringsAsFactors = FALSE)
df <- polls_us_election_2016

df$margin <- df$rawpoll_clinton - df$rawpoll_trump
df <- df[!is.na(df$margin), ]

# ── 2. Statistic Variables ────────────────────────────────────────────────────
n    <- nrow(df)
mu   <- mean(df$margin)
s    <- sd(df$margin)

# ── 3. T-Plots Full, Quality and Bad ──────────────────────────────────────────
binwidth <- 2

x_seq     <- seq(mu - 4 * s, mu + 4 * s, length.out = 300)
t_density <- dt((x_seq - mu) / s, df = n - 1) / s
t_curve   <- data.frame(x = x_seq, y = t_density * n * binwidth)

# T-Plot Full
ggplot(df, aes(x = margin)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_line(data = t_curve, aes(x = x, y = y),
            color = "#D85A30", linewidth = 1) +
  geom_vline(xintercept = mu, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin distribution — all states",
    subtitle = "Clinton minus Trump (raw). Red curve = fitted t-distribution.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/01_tplot_full.png", width = 9, height = 5.5, dpi = 150)

df_quality <- df[df$grade %in% c("A+", "A", "A-", "B+"), ]

n_quality    <- nrow(df_quality)
mu_quality   <- mean(df_quality$margin)
s_quality    <- sd(df_quality$margin)

x_seq_quality     <- seq(mu_quality - 4 * s_quality, mu_quality + 4 * s_quality, length.out = 300)
t_density_quality <- dt((x_seq_quality - mu_quality) / s_quality, df = n_quality - 1) / s_quality
t_curve_quality   <- data.frame(x = x_seq_quality, y = t_density_quality * n_quality * binwidth)

# T-Plot Quality
ggplot(df_quality, aes(x = margin)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_line(data = t_curve_quality, aes(x = x, y = y),
            color = "#D85A30", linewidth = 1) +
  geom_vline(xintercept = mu_quality, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin distribution — quality pollsters (B+ and above)",
    subtitle = "Clinton minus Trump (raw). Red curve = fitted t-distribution.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/02_tplot_quality.png", width = 9, height = 5.5, dpi = 150)

# T-Plot Bad
df_bad <- df[!df$grade %in% c("A+", "A", "A-", "B+"), ]

n_bad    <- nrow(df_bad)
mu_bad   <- mean(df_bad$margin)
s_bad    <- sd(df_bad$margin)

x_seq_bad     <- seq(mu_bad - 4 * s_bad, mu_bad + 4 * s_bad, length.out = 300)
t_density_bad <- dt((x_seq_bad - mu_bad) / s_bad, df = n_bad - 1) / s_bad
t_curve_bad   <- data.frame(x = x_seq_bad, y = t_density_bad * n_bad * binwidth)

ggplot(df_bad, aes(x = margin)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_line(data = t_curve_bad, aes(x = x, y = y),
            color = "#D85A30", linewidth = 1) +
  geom_vline(xintercept = mu_bad, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin distribution — low quality pollsters (below B+)",
    subtitle = "Clinton minus Trump (raw). Red curve = fitted t-distribution.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/03_tplot_bad.png", width = 9, height = 5.5, dpi = 150)

# Each df's averages
mu
mu_quality
mu_bad

# ── 4. Box Plot LV/RV ─────────────────────────────────────────────────────────
# Full
ggplot(df, aes(x = population, y = margin, fill = population)) +
  geom_boxplot(alpha = 0.7, outlier.colour = "grey40", outlier.size = 1.5) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin by voter population type",
    subtitle = "Did likely voter (lv) vs registered voter (rv) polls show different results?",
    x        = "Population type",
    y        = "Clinton − Trump margin (percentage points)",
    fill     = "Population"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/04_boxplot_population_full.png", width = 9, height = 5.5, dpi = 150)

# Quality
ggplot(df_quality, aes(x = population, y = margin, fill = population)) +
  geom_boxplot(alpha = 0.7, outlier.colour = "grey40", outlier.size = 1.5) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin by voter population type (Quality Pollsters B+ or more)",
    subtitle = "Did likely voter (lv) vs registered voter (rv) polls show different results?",
    x        = "Population type",
    y        = "Clinton − Trump margin (percentage points)",
    fill     = "Population"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/05_boxplot_population_quality.png", width = 9, height = 5.5, dpi = 150)

# Bad
ggplot(df_bad, aes(x = population, y = margin, fill = population)) +
  geom_boxplot(alpha = 0.7, outlier.colour = "grey40", outlier.size = 1.5) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin by voter population type (Bad Pollsters B and below)",
    subtitle = "Did likely voter (lv) vs registered voter (rv) polls show different results?",
    x        = "Population type",
    y        = "Clinton − Trump margin (percentage points)",
    fill     = "Population"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/06_boxplot_population_bad.png", width = 9, height = 5.5, dpi = 150)

# ── 5. Leader Time Series ─────────────────────────────────────────────────────
# Full
df$enddate <- as.Date(df$enddate)

ggplot(df, aes(x = enddate, y = margin)) +
  geom_point(alpha = 0.2, size = 1, color = "steelblue", na.rm = TRUE) +
  geom_smooth(method = "loess", color = "blue", se = TRUE, na.rm = TRUE) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin over time — all pollsters",
    subtitle = "Clinton − Trump. Blue line = LOESS smoother. Red line = zero.",
    x        = "Poll end date",
    y        = "Clinton − Trump margin (percentage points)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/07_timeseries_full.png", width = 9, height = 5.5, dpi = 150)


# Quality
df_quality$enddate <- as.Date(df_quality$enddate)

ggplot(df_quality, aes(x = enddate, y = margin)) +
  geom_point(alpha = 0.2, size = 1, color = "steelblue", na.rm = TRUE) +
  geom_smooth(method = "loess", color = "blue", se = TRUE, na.rm = TRUE) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin over time — quality pollsters (B+ and above)",
    subtitle = "Clinton − Trump. Blue line = LOESS smoother. Red line = zero.",
    x        = "Poll end date",
    y        = "Clinton − Trump margin (percentage points)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/08_timeseries_quality.png", width = 9, height = 5.5, dpi = 150)

# Bad
df_bad$enddate <- as.Date(df_bad$enddate)

ggplot(df_bad, aes(x = enddate, y = margin)) +
  geom_point(alpha = 0.2, size = 1, color = "steelblue", na.rm = TRUE) +
  geom_smooth(method = "loess", color = "blue", se = TRUE, na.rm = TRUE) +
  geom_hline(yintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Poll margin over time — bad pollsters (B and below)",
    subtitle = "Clinton − Trump. Blue line = LOESS smoother. Red line = zero.",
    x        = "Poll end date",
    y        = "Clinton − Trump margin (percentage points)"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/09_timeseries_bad.png", width = 9, height = 5.5, dpi = 150)

# ── 6. Weights ────────────────────────────────────────────────────────────────
# Full weight schema
df_clean <- df[!is.na(df$grade) & !is.na(df$margin), ]

df_clean$grade_weight <- ifelse(df_clean$grade == "A+", 4/4,
                                ifelse(df_clean$grade == "A",  3/4,
                                       ifelse(df_clean$grade == "A-", 2/4,
                                              ifelse(df_clean$grade == "B+", 1/4,
                                                     ifelse(df_clean$grade == "B",  0.5/4,
                                                            ifelse(df_clean$grade == "B-", 0.4/4,
                                                                   ifelse(df_clean$grade == "C+", 0.3/4,
                                                                          ifelse(df_clean$grade == "C",  0.2/4,
                                                                                 ifelse(df_clean$grade == "C-", 0.1/4,
                                                                                        ifelse(df_clean$grade == "D",  0.05/4, NA))))))))))

df_clean$weight <- df_clean$grade_weight / df_clean$samplesize
df_clean$weight <- df_clean$weight / sum(df_clean$weight, na.rm = TRUE)

sum(is.na(df_clean$weight))
sum(is.na(df_clean$margin))
sum(is.na(df_clean$grade_weight))

df_clean <- df_clean[!is.na(df_clean$weight), ]
sum(df_clean$weight)

weighted_mu <- weighted.mean(df_clean$margin, df_clean$weight, na.rm = TRUE)
weighted_mu

# Quality
df_clean_quality <- df_clean[df_clean$grade %in% c("A+", "A", "A-", "B+"), ]

weighted_mu_quality <- weighted.mean(df_clean_quality$margin, df_clean_quality$weight, na.rm = TRUE)
weighted_mu_quality

# Bad
df_clean_bad <- df_clean[!df_clean$grade %in% c("A+", "A", "A-", "B+"), ]

weighted_mu_bad <- weighted.mean(df_clean_bad$margin, df_clean_bad$weight, na.rm = TRUE)
weighted_mu_bad

# Summary
cat("Unweighted means:\n")
cat("  All:    ", mu, "\n")
cat("  Quality:", mu_quality, "\n")
cat("  Bad:    ", mu_bad, "\n\n")

cat("Weighted means:\n")
cat("  All:    ", weighted_mu, "\n")
cat("  Quality:", weighted_mu_quality, "\n")
cat("  Bad:    ", weighted_mu_bad, "\n")

cat("Full distribution sample sizes:\n")
cat("  Mean:  ", mean(df$samplesize, na.rm = TRUE), "\n")
cat("  Median:", median(df$samplesize, na.rm = TRUE), "\n\n")

# These stats matter because they add downward pressure on the weights
cat("Quality pollster sample sizes:\n")
cat("  Mean:  ", mean(df_quality$samplesize, na.rm = TRUE), "\n")
cat("  Median:", median(df_quality$samplesize, na.rm = TRUE), "\n\n")

cat("Bad pollster sample sizes:\n")
cat("  Mean:  ", mean(df_bad$samplesize, na.rm = TRUE), "\n")
cat("  Median:", median(df_bad$samplesize, na.rm = TRUE), "\n")

# ── 7. Weighted Distribution Visualizations ───────────────────────────────────
# Full Plot
ggplot(df_clean, aes(x = margin, weight = weight)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_vline(xintercept = weighted_mu, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Weighted poll margin full distribution — all states",
    subtitle = "Clinton minus Trump. Weighted by grade and sample size.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Weighted count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/10_weighted_dist_full.png", width = 9, height = 5.5, dpi = 150)

# Quality Plot
ggplot(df_clean_quality, aes(x = margin, weight = weight)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_vline(xintercept = weighted_mu_quality, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Weighted poll margin quality pollster distribution — all states",
    subtitle = "Clinton minus Trump. Weighted by grade and sample size.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Weighted count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/11_weighted_dist_quality.png", width = 9, height = 5.5, dpi = 150)

# Bad Plot
ggplot(df_clean_bad, aes(x = margin, weight = weight)) +
  geom_histogram(binwidth = binwidth, fill = "#B5D4F4", color = "#185FA5",
                 linewidth = 0.4, alpha = 0.8) +
  geom_vline(xintercept = weighted_mu_bad, color = "#185FA5",
             linewidth = 0.7, linetype = "dashed") +
  geom_vline(xintercept = 0, color = "red", linewidth = 0.7, linetype = "dashed") +
  labs(
    title    = "Weighted poll margin bad pollster distribution — all states",
    subtitle = "Clinton minus Trump. Weighted by grade and sample size.",
    x        = "Clinton − Trump margin (percentage points)",
    y        = "Weighted count"
  ) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(face = "bold"), panel.grid.minor = element_blank())
ggsave("../output/figures/12_weighted_dist_bad.png", width = 9, height = 5.5, dpi = 150)

# ── 8. State Sample Proportions ───────────────────────────────────────────────
state_sample <- aggregate(samplesize ~ state, data = df_clean, FUN = sum)
state_sample <- state_sample[order(-state_sample$samplesize), ]

ggplot(state_sample, aes(x = reorder(state, -samplesize), y = samplesize)) +
  geom_bar(stat = "identity", fill = "#B5D4F4", color = "#185FA5",
           linewidth = 0.3, alpha = 0.8) +
  labs(
    title    = "Total sample size by state",
    subtitle = "Sum of all poll respondents per state. Includes U.S. national polls.",
    x        = "State",
    y        = "Total sample size"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7)
  )
ggsave("../output/figures/13_state_sample_with_us.png", width = 14, height = 5.5, dpi = 150)

df_state <- df_clean[df_clean$state != "U.S.", ]
state_sample <- aggregate(samplesize ~ state, data = df_state, FUN = sum)
state_sample <- state_sample[order(-state_sample$samplesize), ]

ggplot(state_sample, aes(x = reorder(state, -samplesize), y = samplesize)) +
  geom_bar(stat = "identity", fill = "#B5D4F4", color = "#185FA5",
           linewidth = 0.3, alpha = 0.8) +
  labs(
    title    = "Total sample size by state",
    subtitle = "Sum of all poll respondents per state. Excludes U.S. national polls.",
    x        = "State",
    y        = "Total sample size"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7)
  )
ggsave("../output/figures/14_state_sample_without_us.png", width = 14, height = 5.5, dpi = 150)

df_state_quality <- df_clean_quality
df_state_bad     <- df_clean_bad

sample_quality <- aggregate(samplesize ~ state, data = df_state_quality, FUN = sum)
sample_bad     <- aggregate(samplesize ~ state, data = df_state_bad,     FUN = sum)

sample_quality$type <- "Quality (B+ and above)"
sample_bad$type     <- "Bad (below B+)"

state_sample_split <- rbind(sample_quality, sample_bad)

ggplot(state_sample_split, aes(x = reorder(state, -samplesize), y = samplesize, fill = type)) +
  geom_bar(stat = "identity", position = "fill", color = "#185FA5",
           linewidth = 0.2, alpha = 0.8) +
  scale_fill_manual(values = c("Quality (B+ and above)" = "#B5D4F4",
                               "Bad (below B+)"         = "#D85A30")) +
  labs(
    title    = "Proportion of sample size by pollster quality per state",
    subtitle = "Share of total respondents from quality vs low quality pollsters. Includes U.S. national polls.",
    x        = "State",
    y        = "Proportion",
    fill     = "Pollster quality"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title       = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 90, hjust = 1, vjust = 0.5, size = 7)
  )
ggsave("../output/figures/15_proportion_quality_by_state.png", width = 14, height = 5.5, dpi = 150)

# ── 9. Which State Voted for Who ──────────────────────────────────────────────
state_margins <- df_clean %>%
  group_by(state) %>%
  summarise(margin = weighted.mean(margin, weight, na.rm = TRUE)) %>%
  filter(state != "U.S.") %>%
  mutate(state = tolower(state))

# Get US map data
us_map <- map_data("state")

# Join
map_data_merged <- us_map %>%
  left_join(state_margins, by = c("region" = "state"))

ggplot(map_data_merged, aes(x = long, y = lat, group = group, fill = margin)) +
  geom_polygon(color = "white", linewidth = 0.3) +
  scale_fill_gradient2(
    low      = "#D85A30",
    mid      = "white", 
    high     = "#185FA5",
    midpoint = 0,
    name     = "Clinton − Trump\nmargin"
  ) +
  coord_fixed(1.3) +
  labs(
    title    = "Weighted poll margin by state — 2016 US Presidential Election",
    subtitle = "Blue = Clinton leading. Orange = Trump leading.",
    x        = NULL,
    y        = NULL
  ) +
  theme_void(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.background  = element_rect(fill = "white", color = NA),
    legend.position = "right"
  )
ggsave("../output/figures/16_state_heatmap.png", width = 14, height = 5.5, dpi = 150)

# # Unweighted
# state_margins_unweighted <- df_clean %>%
#   group_by(state) %>%
#   summarise(margin = mean(margin, na.rm = TRUE)) %>%
#   filter(state != "U.S.") %>%
#   mutate(state = tolower(state))
# 
# map_data_unweighted <- us_map %>%
#   left_join(state_margins_unweighted, by = c("region" = "state"))
# 
# ggplot(map_data_unweighted, aes(x = long, y = lat, group = group, fill = margin)) +
#   geom_polygon(color = "white", linewidth = 0.3) +
#   scale_fill_gradient2(
#     low      = "#D85A30",
#     mid      = "white",
#     high     = "#185FA5",
#     midpoint = 0,
#     name     = "Clinton − Trump\nmargin"
#   ) +
#   coord_fixed(1.3) +
#   labs(
#     title    = "Unweighted poll margin by state — 2016 US Presidential Election",
#     subtitle = "Blue = Clinton leading. Orange = Trump leading.",
#     x        = NULL,
#     y        = NULL
#   ) +
#   theme_void(base_size = 13) +
#   theme(
#     plot.title      = element_text(face = "bold"),
#     legend.position = "right"
#   )