install.packages("ggdag")
install.packages("dagitty")
library(ggdag)
library(dagitty)

dag_goal <- dagify(
  goal ~ goal_dist,
  goal ~ shot_angle,
  goal ~ one_timer,
  goal ~ behind_net_shot,
  goal ~ through_middle_shot,
  goal ~ shot_after_pass,
  goal ~ period_seconds,
  goal ~ detail_1,
  goal ~ traffic,
  goal ~~ shooter_ability,
  goal ~~ goalie_ability,
  goal ~~ passer_ability,
  goal ~~ pass_difficulty,
  pass_difficulty ~ pass_dist,
  pass_difficulty ~ pass_traffic,
  pass_difficulty ~ pass_type,
  pass_difficulty ~ saucer_pass,
  pass_difficulty ~~ pass_angle)%>%
  tidy_dagitty() %>%
  dag_label(
    labels = c(
      "goal" = "Result of shot\n is a goal",
      "goal_dist" = "Distance of shot",
      "shot_angle" = "Angle of shot",
      "one_timer" = "One-timer",
      "behind_net_shot" = "Shot after pass\n from behind the net",
      "through_middle_shot" = "Shot after pass\n through midline",
      "shot_after_pass" = "Shot within 1 second\n of recieving pass",
      "period_seconds" = "Seconds left\nin the period",
      "detail_1" = "Shot Type",
      "traffic" = "Traffic in between\n shooter and goalie",
      "shooter_ability" = "Shooter Ability",
      "goalie_ability" = "Goalie Ability",
      "passer_ability" = "Passer Ability",
      "pass_difficulty" = "Pass Difficulty",
      "pass_dist" = "Pass Distance",
      "pass_traffic" = '# of Defenders between\n Passer and Shooter',
      "pass_type" = "Type of Pass",
      "saucer_pass" = "Saucer Pass",
      "pass_angle" = "Pass Angle"
      ))
dag_goal_2 <- dag_goal%>%
mutate(
    linetype = ifelse(direction == "<->", "dashed", "solid"),
    latent = ifelse(name == "lockdown", "latent", "observed"),
  ) %>%
  mutate(
    vartype = case_when(
      name == "goal" ~ "iv",
      name == "one_timer" ~ "dv",
      name == "through_middle_shot" ~ "dv",
      name == "behind_net_shot" ~ "dv",
      name == "shot_after_pass" ~ "dv",
      TRUE ~ "control"
    )
  ) %>%
  ggplot(aes(
    x = x,
    y = y,
    xend = xend,
    yend = yend
  )) +
  geom_dag_point(aes(color = vartype), size = 28,
                 show.legend = FALSE) +
  geom_dag_text(aes(label = label), size = 2.25, color = 'black') +
  geom_dag_edges(aes(edge_linetype = linetype),
                 show.legend = FALSE) +
  scale_color_manual(values = c("gray70", "red", "#7875c2")) +
  theme_dag()

dag_goal_2


##PREVIOUS DAG

dag1 <- dagify(
  xG2 ~ detail_1,
  xG2 ~ xG2_dist,
  xG2 ~ shot_angle,
  xG2 ~ traffic,
  xG2 ~ ability,
  xG2 ~ one_timer,
  xG2 ~ traffic,
  xG1 ~~ detail_11,
  xG1 ~ xG1_dist,
  xG1 ~ shot_angle1,
  xG1 ~~ traffic1,
  xG1 ~ ability1,
  xG1 ~ x_y,
  xG2 ~ x2_y2,
  pass_difficulty ~ dist,
  pass_difficulty ~ pass_angle,
  pass_difficulty ~~ pass_deke,
  pass_difficulty ~~ defense,
  pass_difficulty ~~ pass_speed,
  pass_difficulty ~~ pass_traffic,
  xG2 ~~ shot_location,
  xG2 ~~ shot_speed,
  pass_value ~~ pass_difficulty,
  xG_diff ~ xG2,
  xG_diff ~ xG1,
  delta_one_timer ~ one_timer_pct,
  delta_one_timer ~ non_one_timer_pct,
  pass_value ~ delta_one_timer,
  pass_value ~ xG_diff
) %>%
  tidy_dagitty() %>%
  dag_label(
    labels = c(
      "xG2" = "xG2 after\n pass",
      "detail_1" = "shot\n type",
      "xG2_dist" = "shot\n distance",
      "shot_angle" = "shot\n angle",
      "traffic" = "traffic",
      "ability" = "shooter\n ability*",
      "one_timer" = "one-timer\n shot",
      "pass_difficulty" = "passing\n difficulty",
      "x_y" = "passer\n position",
      "x2_y2" = "shooter\n position",
      "dist" = "pass\n distance",
      "pass_angle" = "pass\n angle*",
      "defense" = "opponent\n defense",
      "pass_speed" = "speed\n of pass",
      "pass_traffic" = "traffic\n btwn passer\n and shooter",
      "shot_location" = "shot\n location\n on net",
      "shot_speed" = "shot speed",
      "pass_deke" = "pass deke",
      "xG1_dist" = "distance\n to goal",
      "shot_angle1" = "shot angle\n to net",
      "traffic1" = "traffic\n to net",
      "ability1" = "passer\n ability\n in shooting*",
      "detail_11" = "expected\n shot type",
      "xG1" = "xG1 before\n pass",
      "delta_one_timer" = "actual make pct\n of one-timer\n - actual make pct\n of non-one-timer",
      "xG_diff" = "difference in\n xG btwn\n pass location\n & shot location",
      "pass_value" = "value of\n one-timer pass",
      "one_timer_pct" = "one-timer\n goal pct\n from shot loc",
      "non_one_timer_pct" = "non one-timer\n goal pct\n from shot loc"
    )
  )

# Our DV is the deviation from the standard expected goals of a shot from a specific location
# on the ice. Here, we are looking at the true goal rate/ make pct of a one-timer, compared
# to the xG of a non-one-timer shot taken from the same area.
#
# Our IV is additional value created by making this pass.
# Here, the true value of the pass made to create a one-timer is:
# one-timer pass value = delta(actual make pct of one-timer - actual make pct of non-one timers) +
# (xG of where shot was taken - xG of where pass was made)



#move variables out of the way
 dag1[["data"]][8, 'xend'] <- 3.4
 dag1[["data"]][10, 'xend'] <- 3.4
 
# dag1[["data"]][23, 'yend'] <- -3
# dag1[["data"]][23, 'xend'] <- 1.5
# 
# dag1[["data"]][25, 'yend'] <- -3
# dag1[["data"]][25, 'xend'] <- 1.5
# 
# dag1[["data"]][15, 'direction'] <- "<->"


xG2dag <- dag1 %>%
  mutate(
    linetype = ifelse(direction == "<->", "dashed", "solid"),
    latent = ifelse(name == "lockdown", "latent", "observed"),
  ) %>%
  mutate(
    vartype = case_when(
      name == "xG_diff" ~ "iv",
      name == "delta_one_timer" ~ "iv",
      name == "pass_value" ~ "dv",
      TRUE ~ "control"
    )
  ) %>%
  ggplot(aes(
    x = x,
    y = y,
    xend = xend,
    yend = yend
  )) +
  geom_dag_point(aes(color = vartype), size = 28,
                 show.legend = FALSE) +
  geom_dag_text(aes(label = label), size = 2.25, color = 'black') +
  geom_dag_edges(aes(edge_linetype = linetype),
                 show.legend = FALSE) +
  scale_color_manual(values = c("gray70", "red", "#7875c2")) +
  geom_text(label = 'one-timer pass value = delta(actual make pct of one-timer - actual make pct of non-one timers) +
             normalized(xG of where shot was taken - xG of where pass was made)', x = -2.75, y=3, size=3.5, color = 'black')+
  #annotate("text", label = 'one-timer pass value = delta(actual make pct of one-timer 8- actual make pct of non-one timers) +
   #          normalized(xG of where shot was taken - xG of where pass was made)', x = 10, y=0, size=3, color = 'black')+
  theme_dag()

xG2dag
